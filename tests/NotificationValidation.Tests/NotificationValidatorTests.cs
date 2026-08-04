namespace NotificationValidation.Tests;

public class NotificationValidatorTests
{
    [Theory]
    [InlineData("user@example.com", "email", "Hello", true)]
    [InlineData("not-an-email", "email", "Hello", false)]
    [InlineData("user@example.com", "carrier-pigeon", "Hello", false)]
    [InlineData("user@example.com", "email", "", false)]
    public void Validate_ReturnsExpectedResult(string recipient, string channel, string message, bool expectedValid)
    {
        var (isValid, _) = NotificationValidator.Validate(recipient, channel, message);
        Assert.Equal(expectedValid, isValid);
    }
}