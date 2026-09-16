import { useState } from "react";

function RegisterModal({ onClose, onRegistered }) {
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState("FARMER");
  const [message, setMessage] = useState("");

  async function handleSubmit(event) {
    event.preventDefault();

    if (password.length < 12) {
      setMessage("Password must contain at least 12 characters.");
      return;
    }

    setMessage("Creating your account...");

    try {
      const response = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          fullName,
          email,
          password,
          role
        })
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Account creation failed");
      }

      onRegistered();
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
          aria-label="Close registration form"
        >
          ×
        </button>

        <p>FARMDIRECT ACCOUNT</p>
        <h2>Create account</h2>

        <label htmlFor="register-full-name">Full name</label>
        <input
          id="register-full-name"
          type="text"
          placeholder="Your name or farm name"
          value={fullName}
          onChange={(event) => setFullName(event.target.value)}
          required
        />

        <label htmlFor="register-email">Email</label>
        <input
          id="register-email"
          type="email"
          placeholder="you@example.com"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          required
        />

        <label htmlFor="register-password">Password</label>
        <input
          id="register-password"
          type="password"
          placeholder="Minimum 12 characters"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          minLength="12"
          required
        />

        <label htmlFor="register-role">I am joining as a</label>
        <select
          id="register-role"
          value={role}
          onChange={(event) => setRole(event.target.value)}
        >
          <option value="FARMER">Farmer</option>
          <option value="RETAILER">Retailer</option>
        </select>

        {message && <span className="login-message">{message}</span>}

        <button type="submit">Create secure account</button>

        <button
          type="button"
          className="auth-switch-button"
          onClick={onRegistered}
        >
          Already have an account? Sign in
        </button>
      </form>
    </div>
  );
}

export default RegisterModal;