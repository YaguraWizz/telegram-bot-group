using Telegram.Bot.Types.ReplyMarkups;
using Telegram.Bot.Types;
using Telegram.Bot;
using TelegramBot.Utils.Components;
using System;
using System.Text;

namespace TelegrammBot.Utils.Components
{
    public class CommandProcessor
    {
        private readonly ITelegramBotClient _botClient;
        private readonly Chat _chat;
        private readonly CancellationToken _cancellationToken;

        public CommandProcessor(ITelegramBotClient botClient, Chat chat, CancellationToken cancellationToken)
        {
            _botClient = botClient;
            _chat = chat;
            _cancellationToken = cancellationToken;
        }

        public async Task ProcessStartCommand()
        {
            var messageText = "Добро пожаловать в бота!";
            var replyMarkup = KeyboardHelper.GetReplyKeyboard();
            await SendTextMessageSafely(messageText, replyMarkup);
        }

        public async Task ProcessHelpCommand()
        {
            var messageText = "Вот некоторый текст помощи.";
            var replyMarkup = KeyboardHelper.GetReplyKeyboard();
            await SendTextMessageSafely(messageText, replyMarkup);
        }

        public async Task ProcessListUserCommand()
        {
            var replyMarkup = KeyboardHelper.GetReplyKeyboard();
            var users = UserManager.GetListUsers();
            var activeUsers = users.Where(us => !us.IsMuteUntil());

            var sb = new StringBuilder();
            int index = 1;
            foreach (var user in activeUsers)
            {
                if (user.IsMuteUntil())
                {
                    sb.AppendLine($"{index}. {user.Username} в муте до {user.MuteUntil.Value} по причине {user.MuteUntil.Key}");
                }
                else
                {
                    sb.AppendLine($"{index}. {user.Username}");
                }
                index++;
            }

            var usersWithAt = sb.ToString();
            await SendTextMessageSafely(usersWithAt, replyMarkup);
        }

        public async Task ProcessAllCommand()
        {
            var replyMarkup = KeyboardHelper.GetReplyKeyboard();
            var users = UserManager.GetListUsers();
            var activeUsers = users.Where(us => !us.IsMuteUntil());
            var usersWithAt = string.Join(", ", activeUsers.Select(us => us.IsMuteUntil() ?
                $"{us.Username} в муте до {us.MuteUntil.Value} по причине {us.MuteUntil.Key}" : "@" + us.Username));
            await SendTextMessageSafely(usersWithAt, replyMarkup);
        }


       
        ///////////////////////////////////////////////////////////////////////

        public async Task ProcessMuteCommand(string message, long userId)
        {
            var replyMarkup = KeyboardHelper.GetReplyKeyboard();
            var parseResult = ParseCommand(message);

            if (!parseResult.IsValid)
            {
                var _msg = "Неправильный формат команды. Используйте /mute {время в минутах} {описание}";
                await SendTextMessageSafely(_msg, replyMarkup);
                return;
            }
            var muteUntil = DateTime.Now;
            try
            {
                muteUntil = ParseStringToDateTime(parseResult.Time);
            }
            catch (Exception e)
            {
                var _msg = $"Неправильный формат времени: {parseResult.Time}. Используйте /mute" + " {время в минутах} {описание}\n" + $"Exception: {e.Message}";
                await SendTextMessageSafely(_msg, replyMarkup);
                return;
            }

            var description = parseResult.Description;
            UserManager.MuteUser(userId, description, muteUntil);

            var user = UserManager.GetUser(userId);

            if (user != null)
            {
                var username = user.Username;
                var msg = $"Пользователь {username} замьютился до {muteUntil.ToString("dd.MM.yyyy HH:mm:ss")} по причине: {description}";
                await SendTextMessageSafely(msg, replyMarkup);
            }
            else
            {
                Logger.Log(Logger.Status.ERROR, $"Не удалось отправить сообщение: неизвестно @username");
            }
        }

        public async Task ProcessEventCommand(string message, long userId)
        {
            var replyMarkup = KeyboardHelper.GetReplyKeyboard();
            var parseResult = ParseCommand(message);

            if (!parseResult.IsValid)
            {
                var _msg = "Неправильный формат команды. Используйте /event {время в минутах} {описание}";
                await SendTextMessageSafely(_msg, replyMarkup);
                return;
            }

            var dateTime = DateTime.Now;

            try
            {
                dateTime = ParseStringToDateTime(parseResult.Time);
            }
            catch (Exception e)
            {
                var _msg = $"Неправильный формат времени: {parseResult.Time}. Используйте /event" + " {время в минутах} {описание}\n" + $"Exception: {e.Message}";
                await SendTextMessageSafely(_msg, replyMarkup);
                return;
            }
            var description = parseResult.Description;

            var eventHandler = new EventReminder()
            {
                ID = (int)userId,
                DateTime = (dateTime),
            };

            WrapperEventHandler.Add(eventHandler);

            var user = UserManager.GetUser(userId);

            if (user != null)
            {
                var username = user.Username;
                var msg = $"Пользователь {username} создал событие на {dateTime.ToString("dd.MM.yyyy HH:mm:ss")} с описанием: {description}";
                await SendTextMessageSafely(msg, replyMarkup);
            }
            else
            {
                Logger.Log(Logger.Status.ERROR, $"Не удалось отправить сообщение: неизвестно @username");
            }
        }

        private static (bool IsValid, string Time, string Description) ParseCommand(string message)
        {
            var parts = message.Split(CommandHandler.separator, 3);
            if (parts == null || parts.Length != 3 || !int.TryParse(parts[1], out int minutes))
            {
                return (false, "0", string.Empty);
            }

            var description = parts[2];
            return (true, minutes.ToString(), description);
        }

        public static DateTime ParseStringToDateTime(string input)
        {
            DateTime result;

            if (DateTime.TryParseExact(input, "dd.MM", null, System.Globalization.DateTimeStyles.None, out result))
            {
                // Если строка содержит только день и месяц (без времени)
                return result;
            }
            else if (DateTime.TryParseExact(input, "dd.MM HH:mm", null, System.Globalization.DateTimeStyles.None, out result))
            {
                // Если строка содержит день, месяц и время
                return result;
            }
            else if (DateTime.TryParseExact(input, "dd HH:mm", null, System.Globalization.DateTimeStyles.None, out result))
            {
                // Если строка содержит день, часы и минуты (без месяца и года)
                return DateTime.Today.Add(result.TimeOfDay);
            }
            else if (TimeSpan.TryParseExact(input, "d\\.hh\\:mm", null, out TimeSpan timeSpanResult))
            {
                // Если строка содержит дни, часы и минуты (без даты)
                return DateTime.Today.Add(timeSpanResult);
            }
            else if (TimeSpan.TryParseExact(input, "hh\\:mm", null, out timeSpanResult))
            {
                // Если строка содержит часы и минуты (без даты)
                return DateTime.Today.Add(timeSpanResult);
            }
            else if (TimeSpan.TryParseExact(input, "mm", null, out timeSpanResult))
            {
                // Если строка содержит только минуты (без даты и часов)
                return DateTime.Today.Add(timeSpanResult);
            }
            else
            {
                throw new FormatException("Неверный формат времени");
            }
        }

       

        private async Task SendTextMessageSafely(string text, IReplyMarkup? replyMarkup)
        {
            try
            {
                await _botClient.SendTextMessageAsync(_chat, text, replyMarkup: replyMarkup, cancellationToken: _cancellationToken);
            }
            catch (Exception ex)
            {
                Logger.Log(Logger.Status.ERROR, $"Не удалось отправить сообщение: {ex.Message}");
            }
        }
    }
}

