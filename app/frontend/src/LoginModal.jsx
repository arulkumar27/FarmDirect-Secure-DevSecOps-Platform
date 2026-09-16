import { useState } from "react";

function LoginModal({ onClose, onLogin, onShowRegister }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");

  async function handleSubmit(event) {
    event.preventDefault();
    setMessage("Signing in...");

    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password })
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Login failed");
      }

      localStorage.setItem("farmdirect_token", data.token);
      localStorage.setItem("farmdirect_user", JSON.stringify(data.user));
      onLogin(data.user);
      onClose();
    } catch (error) {
      setMessage(error.message);
    }
  }

  return (
    <div className="modal-backdrop">
      <form className="login-modal" onSubmit={handleSubmit}>
        <button
          type="button"
          className="close-button"
          onClick={onClose}
          aria-label="Close sign in form"
        >
          ×
        </button>

        <p>FARMDIRECT ACCOUNT</p>
        <h2>Sign in</h2>

        <label htmlFor="login-email">Email</label>
        <input
          id="login-email"
          type="email"
          placeholder="you@example.com"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          required
        />

        <label htmlFor="login-password">Password</label>
        <input
          id="login-password"
          type="password"
          placeholder="Enter your password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          required
        />

        {message && <span className="login-message">{message}</span>}

        <button type="submit">Sign in securely</button>

        <button
          type="button"
          className="auth-switch-button"
          onClick={onShowRegister}
        >
          New to FarmDirect? Create an account
        </button>
      </form>
    </div>
  );
}

export default LoginModal;