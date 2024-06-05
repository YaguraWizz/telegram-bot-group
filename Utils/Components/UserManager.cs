using Telegram.Bot.Types;

namespace TelegrammBot.Utils.Components
{
    public static class UserManager
    {
        private static readonly List<User> _users = [];

        public static void AddOrUpdateUser(long userId, string username, string ferstName)
        {
            var existingUser = _users.FirstOrDefault(u => u.UserId == userId);
            if (existingUser != null)
            {
                existingUser.Username = username;
            }
            else
            {
                _users.Add(new User
                {
                    UserId = userId,
                    Username = username,
                    FerstName = ferstName
                });
            }
        }

        public static void MuteUser(long userId, string description, DateTime muteUntil)
        {
            var user = _users.FirstOrDefault(u => u.UserId == userId);
            if (user != null)
            {
                user.SetMuteUntil(description, muteUntil);
            }
        }

        public static bool IsUserMuted(long userId)
        {
            var user = _users.FirstOrDefault(u => u.UserId == userId);
            return user != null && user.IsMuteUntil();
        }


        public static User? GetUser(long userId)
        {
            return _users.FirstOrDefault(u => u.UserId == userId);
        }


        public static List<User> GetListUsers()
        {
            return _users;
        }



        public static string GetMSGUsers()
        {
            var users = _users.FindAll(us => !us.IsMuteUntil());
            var usersWithAt = string.Join(", ", users.Select(us => us.IsMuteUntil() ? us.ToString() : "@" + us));
            return usersWithAt;
        }


        public static int CountUser()    
        {
            return _users.Count;    
        }

    }
}
