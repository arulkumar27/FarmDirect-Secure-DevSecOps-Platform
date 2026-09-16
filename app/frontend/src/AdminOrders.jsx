import { useEffect, useState } from "react";

const statuses = [
  "",
  "PENDING",
  "CONFIRMED",
  "PACKED",
  "OUT_FOR_DELIVERY",
  "DELIVERED",
  "CANCELLED"
];

function AdminOrders() {
  const [dashboard, setDashboard] = useState({
    metrics: {},
    farmers: [],
    orders: []
  });
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [message, setMessage] = useState("Loading admin dashboard...");

  const token = localStorage.getItem("farmdirect_token");

  async function loadDashboard() {
    try {
      setMessage("Loading admin dashboard...");

      const query = new URLSearchParams();

      if (search.trim()) query.set("search", search.trim());
      if (status) query.set("status", status);

      const response = await fetch(`/api/admin/dashboard?${query}`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Unable to load admin dashboard");
      }

      setDashboard(data);
      setMessage("");
    } catch (error) {
      setMessage(error.message);
    }
  }

  useEffect(() => {
    const timer = setTimeout(loadDashboard, 250);
    return () => clearTimeout(timer);
  }, [search, status]);

  async function updateFarmer(farmerId, action) {
    try {
      const response = await fetch(`/api/admin/farmers/${farmerId}/${action}`, {
        method: "PATCH",
        headers: { Authorization: `Bearer ${token}` }
      });

      const data = await response.json();

      if (!response.ok) throw new Error(data.message || "Unable to update farmer");

      await loadDashboard();
    } catch (error) {
      setMessage(error.message);
    }
  }

  async function updateOrderStatus(orderId, newStatus) {
    try {
      const response = await fetch(`/api/admin/orders/${orderId}/status`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ status: newStatus })
      });

      const data = await response.json();

      if (!response.ok) throw new Error(data.message || "Unable to update order");

      await loadDashboard();
    } catch (error) {
      setMessage(error.message);
    }
  }

  const metrics = dashboard.metrics || {};

  return (
    <section className="admin-orders">
      <p>ADMIN DASHBOARD</p>
      <h2>Farm operations control centre</h2>

      <div className="metric-grid">
        <div><span>Pending farmers</span><strong>{metrics.pending_farmers || 0}</strong></div>
        <div><span>Approved farmers</span><strong>{metrics.approved_farmers || 0}</strong></div>
        <div><span>Pending orders</span><strong>{metrics.pending_orders || 0}</strong></div>
        <div><span>Total orders</span><strong>{metrics.total_orders || 0}</strong></div>
      </div>

      <div className="admin-filters">
        <input
          value={search}
          placeholder="Search farmer, retailer, email or order ID"
          onChange={(event) => setSearch(event.target.value)}
        />

        <select value={status} onChange={(event) => setStatus(event.target.value)}>
          {statuses.map((item) => (
            <option key={item || "all"} value={item}>
              {item ? item.replaceAll("_", " ") : "All order statuses"}
            </option>
          ))}
        </select>
      </div>

      {message && <span className="form-message">{message}</span>}

      {!message && (
        <>
          <h3>Farmer accounts</h3>

          <div className="order-table">
            <div className="table-heading farmer-heading">
              <span>Farmer</span>
              <span>Account status</span>
              <span>Action</span>
            </div>

            {dashboard.farmers.map((farmer) => (
              <div className="table-row farmer-row" key={farmer.id}>
                <span>
                  <strong>{farmer.full_name}</strong>
                  <small>{farmer.email}</small>
                </span>

                <span className={`status-badge status-${farmer.account_status.toLowerCase()}`}>
                  {farmer.account_status}
                </span>

                <span className="card-actions">
                  {farmer.account_status === "PENDING" && (
                    <button type="button" onClick={() => updateFarmer(farmer.id, "approve")}>
                      Approve
                    </button>
                  )}

                  {farmer.account_status === "APPROVED" && (
                    <button className="danger-button" type="button" onClick={() => updateFarmer(farmer.id, "suspend")}>
                      Suspend
                    </button>
                  )}
                </span>
              </div>
            ))}
          </div>

          <h3>Retailer orders</h3>

          {dashboard.orders.length === 0 ? (
            <p className="empty-state">No matching retailer orders.</p>
          ) : (
            <div className="order-table">
              <div className="table-heading">
                <span>Order</span>
                <span>Retailer</span>
                <span>Total</span>
                <span>Status</span>
              </div>

              {dashboard.orders.map((order) => (
                <div className="table-row" key={order.id}>
                  <span>#{order.id}</span>
                  <span>
                    <strong>{order.retailer_name}</strong>
                    <small>{order.retailer_email}</small>
                  </span>
                  <span>₹{Number(order.total_amount).toFixed(2)}</span>

                  <select
                    className="order-status-select"
                    value={order.status}
                    onChange={(event) => updateOrderStatus(order.id, event.target.value)}
                  >
                    {statuses.slice(1).map((item) => (
                      <option key={item} value={item}>
                        {item.replaceAll("_", " ")}
                      </option>
                    ))}
                  </select>
                </div>
              ))}
            </div>
          )}
        </>
      )}
    </section>
  );
}

export default AdminOrders;