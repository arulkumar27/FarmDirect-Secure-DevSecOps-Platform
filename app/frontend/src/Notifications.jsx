import { useEffect, useState } from "react";

function Notifications() {
  const [notifications, setNotifications] = useState([]);
  const [isOpen, setIsOpen] = useState(false);

  const token = localStorage.getItem("farmdirect_token");

  async function loadNotifications() {
    try {
      const response = await fetch("/api/notifications", {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });

      const data = await response.json();

      if (response.ok) {
        setNotifications(data.notifications || []);
      }
    } catch {
      // Notification failure must not affect the main app.
    }
  }

  useEffect(() => {
    loadNotifications();

    const intervalId = setInterval(loadNotifications, 30000);

    return () => clearInterval(intervalId);
  }, []);

  async function toggleNotifications() {
    const nextOpenState = !isOpen;
    setIsOpen(nextOpenState);

    if (!nextOpenState) return;

    await fetch("/api/notifications/read-all", {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    setNotifications((current) =>
      current.map((notification) => ({
        ...notification,
        is_read: true
      }))
    );
  }

  const unreadCount = notifications.filter(
    (notification) => !notification.is_read
  ).length;

  return (
    <div className="notification-wrapper">
      <button
        type="button"
        className="notification-button"
        onClick={toggleNotifications}
        aria-label="Open notifications"
      >
        🔔

        {unreadCount > 0 && (
          <span className="notification-count">
            {unreadCount > 9 ? "9+" : unreadCount}
          </span>
        )}
      </button>

      {isOpen && (
        <section className="notification-panel">
          <div className="notification-panel-header">
            <strong>Notifications</strong>
            <span>{notifications.length}</span>
          </div>

          {notifications.length === 0 ? (
            <p className="empty-state">No notifications yet.</p>
          ) : (
            <div className="notification-list">
              {notifications.map((notification) => (
                <article
                  className={`notification-item ${
                    notification.is_read ? "" : "unread"
                  }`}
                  key={notification.id}
                >
                  <strong>{notification.title}</strong>
                  <p>{notification.message}</p>
                  <small>
                    {new Date(notification.created_at).toLocaleString()}
                  </small>
                </article>
              ))}
            </div>
          )}
        </section>
      )}
    </div>
  );
}

export default Notifications;