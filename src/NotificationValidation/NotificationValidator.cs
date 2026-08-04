namespace NotificationValidation;

public static class NotificationValidator
{
    private static readonly string[] ValidChannels = { "email", "sms", "push" };
    private const int MaxMessageLength = 500;

    public static (bool IsValid, string? Error) Validate(string recipient, string channel, string message)
    {
        if (string.IsNullOrWhiteSpace(recipient) || !recipient.Contains('@'))
            return (false, "Invalid recipient: must be a non-empty value containing '@'");

        if (string.IsNullOrWhiteSpace(channel) || !ValidChannels.Contains(channel))
            return (false, $"Invalid channel: must be one of {string.Join(", ", ValidChannels)}");

        if (string.IsNullOrWhiteSpace(message) || message.Length > MaxMessageLength)
            return (false, $"Invalid message: must be non-empty and under {MaxMessageLength} characters");

        return (true, null);
    }
}