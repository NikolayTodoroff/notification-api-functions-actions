using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using NotificationValidation;

namespace NotificationApi;

public class PostNotification
{
    private readonly ILogger<PostNotification> _logger;

    public PostNotification(ILogger<PostNotification> logger)
    {
        _logger = logger;
    }

    [Function("PostNotification")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = "notifications")] HttpRequestData req)
    {
        var requestBody = await new StreamReader(req.Body).ReadToEndAsync();

        NotificationRequest? notification;
        try
        {
            notification = JsonSerializer.Deserialize<NotificationRequest>(requestBody, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
        }
        catch (JsonException)
        {
            return await CreateResponse(req, HttpStatusCode.BadRequest, "Invalid JSON format");
        }

        if (notification is null)
        {
            return await CreateResponse(req, HttpStatusCode.BadRequest, "Invalid request body");
        }

        var (isValid, error) = NotificationValidator.Validate(
            notification.Recipient, notification.Channel, notification.Message);

        if (!isValid)
        {
            return await CreateResponse(req, HttpStatusCode.BadRequest, error!);
        }

        _logger.LogInformation("Notification dispatched to {Recipient} via {Channel}",
            notification.Recipient, notification.Channel);

        return await CreateResponse(req, HttpStatusCode.OK, "Dispatched");
    }

    private static async Task<HttpResponseData> CreateResponse(HttpRequestData req, HttpStatusCode status, string message)
    {
        var response = req.CreateResponse(status);
        await response.WriteAsJsonAsync(new { message });
        return response;
    }
}

public record NotificationRequest(string Recipient, string Channel, string Message, string? Priority);