namespace TelegrammBot.Utils.Components
{
    public class User
    {
        public long UserId { get; set; }
        public string? Username { get; set; }
        public string? FerstName { get; set; }
        public KeyValuePair<string, DateTime> MuteUntil { get; set; }

        public bool IsMuteUntil()
        {
            return DateTime.UtcNow < MuteUntil.Value;   
        }

        public void SetMuteUntil(string dis, DateTime date)
        {
            MuteUntil = new KeyValuePair<string, DateTime>(dis, date);
        }

    }

}
