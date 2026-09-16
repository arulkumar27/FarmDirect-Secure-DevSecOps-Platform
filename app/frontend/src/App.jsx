import { useEffect, useState } from "react";
import LoginModal from "./LoginModal";
import RegisterModal from "./RegisterModal";
import Notifications from "./Notifications";
import ProductForm from "./ProductForm";
import OrderForm from "./OrderForm";
import AdminOrders from "./AdminOrders";
import "./App.css";

function App() {
  const [products, setProducts] = useState([]);
  const [message, setMessage] = useState("Loading products...");
  const [showLogin, setShowLogin] = useState(false);
  const [showRegister, setShowRegister] = useState(false);

  const [user, setUser] = useState(() => {
    const savedUser = localStorage.getItem("farmdirect_user");
    return savedUser ? JSON.parse(savedUser) : null;
  });

  function loadProducts() {
    setMessage("Loading products...");

    fetch("/api/products")
      .then((response) => {
        if (!response.ok) throw new Error("API failed");
        return response.json();
      })
      .then((data) => {
        setProducts(data.products || []);
        setMessage("");
      })
      .catch(() => {
        setMessage("Backend is unavailable. Check Docker containers.");
      });
  }

  useEffect(() => {
    loadProducts();
  }, []);

  function logout() {
    localStorage.removeItem("farmdirect_token");
    localStorage.removeItem("farmdirect_user");
    setUser(null);
  }

  return (
    <main className="app">
      <header>
        <p className="logo">Farm<span>Direct</span></p>

        {user ? (
          <div className="user-menu">
            <Notifications />
            <span>Hi, {user.fullName}</span>
            <button type="button" onClick={logout}>Logout</button>
          </div>
        ) : (
          <button type="button" onClick={() => setShowLogin(true)}>
            Login
          </button>
        )}
      </header>

      <section className="hero">
        <p>FARM-TO-RETAIL PLATFORM</p>
        <h1>Fresh produce, directly from trusted farmers.</h1>
        <span>
          Secure inventory and order management for farmers and retailers.
        </span>
      </section>

      {user?.role === "FARMER" && (
        <ProductForm onProductAdded={loadProducts} />
      )}

      {user?.role === "RETAILER" && (
        <OrderForm products={products} onOrderPlaced={loadProducts} />
      )}

      {user?.role === "ADMIN" && <AdminOrders />}

      <section className="products">
        <p>LIVE INVENTORY</p>
        <h2>Available produce</h2>

        {message && <p className="message">{message}</p>}

        <div className="product-grid">
          {products.map((product) => (
            <article className="product-card" key={product.id}>
              <div>🌿</div>
              <small>{product.category || "Fresh produce"}</small>
              <h3>{product.product_name}</h3>
              <p>Sold by {product.farmer_name}</p>
              <strong>₹{product.price_per_unit} / {product.unit}</strong>
              <span>
                {product.available_quantity} {product.unit} in stock
              </span>
            </article>
          ))}
        </div>
      </section>

      {showLogin && (
        <LoginModal
          onClose={() => setShowLogin(false)}
          onLogin={(loggedInUser) => setUser(loggedInUser)}
          onShowRegister={() => {
            setShowLogin(false);
            setShowRegister(true);
          }}
        />
      )}

      {showRegister && (
        <RegisterModal
          onClose={() => setShowRegister(false)}
          onRegistered={() => {
            setShowRegister(false);
            setShowLogin(true);
          }}
        />
      )}
    </main>
  );
}

export default App;