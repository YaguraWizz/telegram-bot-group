using System.Text.Json;

namespace TelegrammBot.Utils
{
    public static class UserSaveHelper
    {
        private static readonly string FilePath = "data.json";

        public static void SaveData<T>(List<T> data)
        {
            var jsonString = JsonSerializer.Serialize(data);
            File.WriteAllText(FilePath, jsonString);
        }

        public static List<T>? LoadData<T>()
        {
            if (File.Exists(FilePath))
            {
                var jsonString = File.ReadAllText(FilePath);
                return JsonSerializer.Deserialize<List<T>>(json: jsonString);
            }
            else
            {
                return [];
            }
        }
    }
}
