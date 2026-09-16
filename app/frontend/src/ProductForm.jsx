import { useEffect, useState } from "react";

const emptyForm = {
  productName: "",
  category: "",
  unit: "kg",
  price: "",
  quantity: ""
};

function ProductForm({ onProductAdded }) {
  const [form, setForm] = useState(emptyForm);
  const [myProducts, setMyProducts] = useState([]);
  const [editingProduct, setEditingProduct] = useState(null);
  const [message, setMessage] = useState("");

  const token = localStorage.getItem("farmdirect_token");

  async function loadMyProducts() {
    const response = await fetch("/api/products/mine", {
      headers: { Authorization: `Bearer ${token}` }
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || "Unable to load your products");
    }

    setMyProducts(data.products || []);
  }

  useEffect(() => {
    loadMyProducts().catch((error) => setMessage(error.message));
  }, []);

  function updateField(event) {
    setForm({ ...form, [event.target.name]: event.target.value });
  }

  async function handleSubmit(event) {
    event.preventDefault();
    setMessage("Adding product...");

    try {
      const response = await fetch("/api/products", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
          productName: form.productName,
          category: form.category,
          unit: form.unit,
          pricePerUnit: Number(form.price),
          availableQuantity: Number(form.quantity)
        })
      });

      const data = await response.json();

      if (!response.ok) throw new Error(data.message || "Unable to add product");

      setForm(emptyForm);
      setMessage("Product added successfully.");
      await loadMyProducts();
      onProductAdded();
    } catch (error) {
      setMessage(error.message);
    }
  }

  function startEdit(product) {
    setEditingProduct({
      id: product.id,
      productName: product.product_name,
      category: product.category || "",
      unit: product.unit,
      price: product.price_per_unit,
      quantity: product.available_quantity
    });
  }

  async function saveEdit(event) {
    event.preventDefault();

    try {
      const response = await fetch(`/api/products/${editingProduct.id}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
          productName: editingProduct.productName,
          category: editingProduct.category,
          unit: editingProduct.unit,
          pricePerUnit: Number(editingProduct.price),
          availableQuantity: Number(editingProduct.quantity)
        })
      });

      const data = await response.json();

      if (!response.ok) throw new Error(data.message || "Unable to update product");

      setEditingProduct(null);
      setMessage("Product updated successfully.");
      await loadMyProducts();
      onProductAdded();
    } catch (error) {
      setMessage(error.message);
    }
  }

  async function deleteProduct(productId) {
    if (!window.confirm("Delete this product permanently?")) return;

    try {
      const response = await fetch(`/api/products/${productId}`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${token}` }
      });

      const data = await response.json();

      if (!response.ok) throw new Error(data.message || "Unable to delete product");

      setMessage("Product deleted successfully.");
      await loadMyProducts();
      onProductAdded();
    } catch (error) {
      setMessage(error.message);
    }
  }

  return (
    <>
      <section className="add-product">
        <p>FARMER DASHBOARD</p>
        <h2>Add fresh produce</h2>

        <form onSubmit={handleSubmit}>
          <input name="productName" placeholder="Product name" value={form.productName} onChange={updateField} required />
          <input name="category" placeholder="Category (Vegetables)" value={form.category} onChange={updateField} />
          <input name="price" type="number" min="1" placeholder="Price per unit (₹)" value={form.price} onChange={updateField} required />
          <input name="quantity" type="number" min="0" placeholder="Available quantity" value={form.quantity} onChange={updateField} required />

          <select name="unit" value={form.unit} onChange={updateField}>
            <option value="kg">kg</option>
            <option value="piece">piece</option>
            <option value="box">box</option>
          </select>

          <button type="submit">Add product</button>
        </form>

        {message && <span className="form-message">{message}</span>}
      </section>

      <section className="manage-section">
        <p>MY INVENTORY</p>
        <h2>Manage your products</h2>

        {myProducts.length === 0 ? (
          <p className="empty-state">You have not added products yet.</p>
        ) : (
          <div className="manage-grid">
            {myProducts.map((product) => (
              <article className="manage-card" key={product.id}>
                <small>{product.category || "Fresh produce"}</small>
                <h3>{product.product_name}</h3>
                <p>₹{product.price_per_unit} / {product.unit}</p>
                <strong>{product.available_quantity} {product.unit} available</strong>

                <div className="card-actions">
                  <button type="button" onClick={() => startEdit(product)}>Edit</button>
                  <button className="danger-button" type="button" onClick={() => deleteProduct(product.id)}>Delete</button>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>

      {editingProduct && (
        <section className="edit-product">
          <h2>Edit {editingProduct.productName}</h2>

          <form onSubmit={saveEdit}>
            <input value={editingProduct.productName} onChange={(event) => setEditingProduct({ ...editingProduct, productName: event.target.value })} required />
            <input value={editingProduct.category} onChange={(event) => setEditingProduct({ ...editingProduct, category: event.target.value })} placeholder="Category" />
            <input type="number" min="1" value={editingProduct.price} onChange={(event) => setEditingProduct({ ...editingProduct, price: event.target.value })} required />
            <input type="number" min="0" value={editingProduct.quantity} onChange={(event) => setEditingProduct({ ...editingProduct, quantity: event.target.value })} required />

            <select value={editingProduct.unit} onChange={(event) => setEditingProduct({ ...editingProduct, unit: event.target.value })}>
              <option value="kg">kg</option>
              <option value="piece">piece</option>
              <option value="box">box</option>
            </select>

            <button type="submit">Save changes</button>
            <button className="secondary-button" type="button" onClick={() => setEditingProduct(null)}>Cancel</button>
          </form>
        </section>
      )}
    </>
  );
}

export default ProductForm;