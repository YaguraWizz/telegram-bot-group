using System;

namespace TelegramBot.Utils.Components
{
    public class BaseEventWrapper
    {
        public int ID { get; set; }
        public EventStatus EventStatus { get; set; }
        public Action? Action { get; set; }

        public void ChangeStatus()
        {
            if (EventStatus == EventStatus.Start)
            {
                EventStatus = EventStatus.End;
            }
        }

    }

    public class EventReminder : BaseEventWrapper
    {
        public DateTime DateTime { get; set; } = DateTime.Now;

        public EventReminder()
        {
            Action = Reminder;
        }

        public void Reminder()
        {
            if (DateTime.Date == DateTime.Now.Date && DateTime.Hour == DateTime.Now.Hour && DateTime.Minute == DateTime.Now.Minute)
            {
                base.ChangeStatus();
            }
        }
    }

    public enum EventStatus
    {
        Start, End
    }
}
