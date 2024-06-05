using Telegram.Bot.Types.ReplyMarkups;

namespace TelegrammBot.Utils.Components
{
    public static class KeyboardHelper
    {
        public static ReplyKeyboardMarkup GetReplyKeyboard()
        {
            return new ReplyKeyboardMarkup(new[]
            {
                new[]
                {
                   new KeyboardButton("/start"),
                   new KeyboardButton("/all"),
                   new KeyboardButton("/list"),
                   new KeyboardButton("/help"),
                }
            })
            {
                ResizeKeyboard = true, // Позволяет изменять размер клавиатуры в зависимости от количества кнопок
                OneTimeKeyboard = true, // Убирает клавиатуру после нажатия на кнопку
            };
        }
    }
}
