using Telegram.Bot;
using Telegram.Bot.Types;
using Telegram.Bot.Types.Enums;
using TelegramBot.Utils.Components;


namespace TelegrammBot.Utils.Components
{
    public class RootCommand
    {
        public async Task ProcessMessage(ITelegramBotClient botClient, Message message, CancellationToken cancellationToken)
        {
            if (string.IsNullOrEmpty(message.Text)) { return; }
            if (!FillChat(message.Chat.Type)) { return; }

            // Пример обработки команды
            if (message.Text.StartsWith("/"))
            {
                var commandHandler = new CommandHandler();
                Logger.Log(Logger.Status.INFO, $"Received message in chat of type: {message.Chat.Type}, Command: {message.Text}");
                await commandHandler.ExecuteCommand(botClient, message, cancellationToken);
            }
            else
            {
                // Обработка других сообщений
                Logger.Log(Logger.Status.INFO, $"Received message: {message.Text}");
            }
        }

        private bool FillChat(ChatType type)
        {
            // Проверяем тип чата
            if (type == ChatType.Private || type == ChatType.Group || type == ChatType.Supergroup)
            {
                // Личное сообщение или сообщение в групповом или супергрупповом чате

                return true;
            }
            return false;
        }
    }
}
