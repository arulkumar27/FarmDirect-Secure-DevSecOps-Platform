import { useEffect, useState } from "react";

function OrderForm({ products, onOrderPlaced }) {
  const [productId, setProductId] = useState("");
  const [quantity, setQuantity] = useState("");
  const [orders, setOrders] = useState([]);
  const [message, setMessage] = useState("");

  const token = localStorage.getItem("farmdirect_token");

  async function loadMyOrders() {
    const response = await fetch("/api/orders/mine", {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || "Unable to load order history");
    }

    setOrders(data.orders || []);
  }

  useEffect(() => {
    loadMyOrders().catch((error) => setMessage(error.message));
  }, []);

  async function handleSubmit(event) {
    event.preventDefault();

    if (!productId || !quantity) {
      setMessage("Select a product and enter quantity.");
      return;
    }

    setMessage("Placing order...");

    try {
      const response = await fetch("/api/orders", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
          items: [
            {
              productId: Number(productId),
              quantity: Number(quantity)
            }
          ]
        })
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Unable to place order");
      }

      setMessage(`Order #${data.order.id} placed successfully.`);
      setProductId("");
      setQuantity("");

      await loadMyOrders();
      onOrderPlaced();
    } catch (error) {
      setMessage(error.message);
    }
  }

  return (
    <>
      <section className="add-product">
        <p>RETAILER DASHBOARD</p>
        <h2>Place a fresh produce order</h2>

        <form onSubmit={handleSubmit}>
          <select
            value={productId}
            onChange={(event) => setProductId(event.target.value)}
            required
          >
            <option value="">Select produce</option>

            {products.map((product) => (
              <option key={product.id} value={product.id}>
                {product.product_name} — ₹{product.price_per_unit}/{product.unit}
                {" "}({product.available_quantity} available)
              </option>
            ))}
          </select>

          <input
            type="number"
            min="1"
            placeholder="Quantity"
            value={quantity}
            onChange={(event) => setQuantity(event.target.value)}
            required
          />

          <button type="submit">Place secure order</button>
        </form>

        {message && <span className="form-message">{message}</span>}
      </section>

      <section className="manage-section">
        <p>ORDER HISTORY</p>
        <h2>Track your orders</h2>

        {orders.length === 0 ? (
          <p className="empty-state">You have not placed an order yet.</p>
        ) : (
          <div className="order-history">
            {orders.map((order) => (
              <article className="order-history-card" key={order.id}>
                <div>
                  <strong>Order #{order.id}</strong>

                  <span
                    className={`status-badge status-${order.status.toLowerCase()}`}
                  >
                    {order.status.replaceAll("_", " ")}
                  </span>
                </div>

                <p>
                  {order.items.map((item) => (
                    <span key={`${order.id}-${item.productName}`}>
                      {item.productName} · {item.quantity} {item.unit}
                    </span>
                  ))}
                </p>

                <strong>₹{Number(order.total_amount).toFixed(2)}</strong>
              </article>
            ))}
          </div>
        )}
      </section>
    </>
  );
}

export default OrderForm;