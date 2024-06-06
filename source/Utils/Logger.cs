using System;
using System.IO;

namespace TelegrammBot.Utils
{
    public class Logger
    {
        // Enum to define log status types
        public enum Status
        {
            ERROR,
            COMPLETE,
            COMMAND,
            INFO
        }

        // Path to log file
        private static string logFilePath = "logs/log.txt"; // Используем прямой слеш для кроссплатформенности
        private static bool logToConsole = true;

        // Method to set log file path
        public static void SetLogFilePath(string path)
        {
            logFilePath = path ?? throw new ArgumentNullException(nameof(path));
        }

        // Method to log messages
        public static void Log(Status status, string message)
        {
            string logMessage = $"{DateTime.Now} - {status}: {message}";
            if (logToConsole) { Console.WriteLine(logMessage); }
            WriteLogToFile(logMessage);
        }

        // Helper method to write log message to file
        private static void WriteLogToFile(string message)
        {
            try
            {
                // Ensure the directory exists
                string? directoryPath = Path.GetDirectoryName(logFilePath);
                if (directoryPath != null && !Directory.Exists(directoryPath))
                {
                    Directory.CreateDirectory(directoryPath);
                }

                using (StreamWriter writer = new StreamWriter(logFilePath, true))
                {
                    writer.WriteLine(message);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to write to log file: {ex.Message}\n{ex.StackTrace}");
                Environment.Exit(-1); // Завершить программу при критической ошибке
            }
        }
    }
}
