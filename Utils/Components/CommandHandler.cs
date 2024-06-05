using Telegram.Bot;
using Telegram.Bot.Types;
using Telegram.Bot.Types.ReplyMarkups;
using TelegrammBot.Utils;
using TelegrammBot.Utils.Components;


namespace TelegramBot.Utils.Components
{
    public class CommandHandler
    {
        public static readonly char[] separator = [' '];
#pragma warning disable CS8604 // Возможно, аргумент-ссылка, допускающий значение NULL.
#pragma warning disable CS8602 // Разыменование вероятной пустой ссылки.
        public async Task ExecuteCommand(ITelegramBotClient botClient, Message message, CancellationToken cancellationToken)
        {
            if (message == null || message.From == null || string.IsNullOrEmpty(message.From.Username))
            {
                var errorMessage = "Ошибка выполнения: сообщение или его отправитель не определены!";
                Logger.Log(Logger.Status.ERROR, errorMessage);
                return;
            }

            var userId = message.From.Id;
            var username = message.From.Username;
            var firstname = message.From.FirstName;
            var chat = message.Chat;


            UserManager.AddOrUpdateUser(userId, username, firstname);

            var parts = message?.Text?.Split(separator, StringSplitOptions.RemoveEmptyEntries);
            if (parts == null || parts.Length <= 0)
            {
                var errorMessage = "Ошибка выполнения: текст сообщения не определен!";
                await SendTextMessageSafely(botClient, chat, errorMessage, null, cancellationToken);
                Logger.Log(Logger.Status.ERROR, errorMessage);
                return;
            }

            var command = parts[0];
            switch (command)
            {
                case "/start":
                    await new CommandProcessor(botClient, chat, cancellationToken).ProcessStartCommand();
                    break;
                case "/help":
                    await new CommandProcessor(botClient, chat, cancellationToken).ProcessHelpCommand();
                    break;
                case "/all":
                    await new CommandProcessor(botClient, chat, cancellationToken).ProcessAllCommand();
                    break;
                case "/list":
                    await new CommandProcessor(botClient, chat, cancellationToken).ProcessListUserCommand();
                    break;
                case "/mute":
                    await new CommandProcessor(botClient, chat, cancellationToken).ProcessMuteCommand(message.Text, userId);
                    break;
                case "/event":
                    await new CommandProcessor(botClient, chat, cancellationToken).ProcessEventCommand(message.Text, userId);
                    break;
                default:
                    await UnknownCommandSendText(botClient, chat, cancellationToken);
                    break;
            }
        }
#pragma warning restore CS8602 // Разыменование вероятной пустой ссылки.
#pragma warning restore CS8604 // Возможно, аргумент-ссылка, допускающий значение NULL.
       
        private async Task UnknownCommandSendText(ITelegramBotClient botClient, Chat chat, CancellationToken cancellationToken)
        {
            var messageText = "Неизвестная команда.";
            await SendTextMessageSafely(botClient, chat, messageText, null, cancellationToken);
        }

        private static async Task SendTextMessageSafely(ITelegramBotClient botClient, Chat chat, string text, IReplyMarkup? replyMarkup, CancellationToken cancellationToken)
        {
            try
            {
                await botClient.SendTextMessageAsync(chat, text, replyMarkup: replyMarkup, cancellationToken: cancellationToken);
            }
            catch (Exception ex)
            {
                Logger.Log(Logger.Status.ERROR, $"Не удалось отправить сообщение: {ex.Message}");
            }
        }
    }
}
