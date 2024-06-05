using Telegram.Bot;
using Telegram.Bot.Exceptions;
using Telegram.Bot.Polling;
using Telegram.Bot.Types;
using Telegram.Bot.Types.Enums;
using TelegrammBot.Utils;
using TelegrammBot.Utils.Components;

namespace TelegrammBot
{
    internal class Program
    {
        static async Task Main(string[] args)
        {
            TelegramBotService telegramBot = new TelegramBotService();
            await telegramBot.Start();
        }
    }

    public class TelegramBotService
    {
        private static readonly string _token = "7069390034:AAFWObAPUsIgZbxZTphdchSK8i-eMIJBa8Y";
        private readonly TelegramBotClient _botClient;
       

       
        public TelegramBotService()
        {
            _botClient = new TelegramBotClient(_token);
        }

        public async Task Start()
        {
            if (!await CheckTokenValidityAsync())
            {
                Console.WriteLine("Invalid token.");
                Environment.Exit(-1);
            }

            var cts = new CancellationTokenSource();

            ReceiverOptions receiverOptions = new()
            {
                AllowedUpdates = Array.Empty<UpdateType>() // receive all update types
            };

            _botClient.StartReceiving(
                HandleUpdateAsync,
                HandleErrorAsync,
                receiverOptions,
                cts.Token
            );

            Console.WriteLine("Bot is up and running");
            await Task.Delay(-1); // Keep the bot running
        }

        private async Task HandleUpdateAsync(ITelegramBotClient botClient, Update update, CancellationToken cancellationToken)
        {
            if (update.Message is not { } message)
                return;

            if (message.Text is not { } messageText)
                return;

            var rootCommand = new RootCommand();
            await rootCommand.ProcessMessage(botClient, message, cancellationToken);
        }

        private Task HandleErrorAsync(ITelegramBotClient botClient, Exception exception, CancellationToken cancellationToken)
        {
            var errorMessage = exception switch
            {
                ApiRequestException apiRequestException
                    => $"Telegram API Error:[{apiRequestException.ErrorCode}]\t{apiRequestException.Message}",
                _ => exception.ToString()
            };

            Logger.Log(Logger.Status.ERROR, errorMessage);
            Environment.Exit(-1); // Завершить программу при ошибке
            return Task.CompletedTask;
        }

        private async Task<bool> CheckTokenValidityAsync()
        {
            try
            {
                var me = await _botClient.GetMeAsync();
                Console.WriteLine($"Bot Id: {me.Id}, Bot Name: {me.FirstName}");
                return true;
            }
            catch (ApiRequestException ex)
            {
                Logger.Log(Logger.Status.ERROR, $"Invalid token: {ex.Message}");
                return false;
            }
        }
    }
}



