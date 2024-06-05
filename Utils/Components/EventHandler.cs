using TelegramBot.Utils.Components;

namespace TelegrammBot.Utils.Components
{
    public static class WrapperEventHandler
    {
        private static readonly List<BaseEventWrapper> EventList = new List<BaseEventWrapper>();
        private static readonly object LockObject = new object();
        private static readonly CancellationTokenSource CancellationTokenSource = new CancellationTokenSource();
        private static Task TaskHandler { get; set; }

        static WrapperEventHandler()
        {
            TaskHandler = Task.Factory.StartNew(TaskHandlerEventWrapper, CancellationTokenSource.Token, TaskCreationOptions.LongRunning, TaskScheduler.Default);
        }

        public static void Add(BaseEventWrapper e)
        {
            lock (LockObject)
            {
                if (EventList.Contains(e)) return;
                EventList.Add(e);
            }
        }

        private static void TaskHandlerEventWrapper()
        {
            while (!CancellationTokenSource.Token.IsCancellationRequested)
            {
                List<BaseEventWrapper> itemsToProcess;

                lock (LockObject)
                {
                    itemsToProcess = EventList.Where(item => item.EventStatus != EventStatus.End).ToList();
                }

                foreach (var item in itemsToProcess)
                {
                    item?.Action?.Invoke();
                }

                UpdateList();
                Thread.Sleep(1000); // Ждем 1 секунду перед следующим циклом
            }
        }

        public static void UpdateList()
        {
            lock (LockObject)
            {
                EventList.RemoveAll(item => item.EventStatus == EventStatus.End);
            }
        }

        public static void StopHandler()
        {
            CancellationTokenSource.Cancel();
        }
    }
}
