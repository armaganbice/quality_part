import React, { useState } from 'react';

const Cart = () => {
  // Mock sepet verisi
  const [cartItems, setCartItems] = useState([
    { id: 1, name: 'Gömlek', price: 149.99, quantity: 1, image: 'https://via.placeholder.com/100x100?text=Gömlek' },
    { id: 2, name: 'Pantolon', price: 249.99, quantity: 1, image: 'https://via.placeholder.com/100x100?text=Pantolon' },
  ]);

  const removeFromCart = (id) => {
    setCartItems(cartItems.filter(item => item.id !== id));
  };

  const updateQuantity = (id, newQuantity) => {
    if (newQuantity === 0) {
      removeFromCart(id);
      return;
    }
    
    setCartItems(cartItems.map(item => 
      item.id === id ? { ...item, quantity: newQuantity } : item
    ));
  };

  const getTotalPrice = () => {
    return cartItems.reduce((total, item) => total + (item.price * item.quantity), 0).toFixed(2);
  };

  return (
    <div className="cart-page py-8">
      <div className="container mx-auto">
        <h1 className="text-3xl font-bold mb-6">Alışveriş Sepeti</h1>
        
        {cartItems.length === 0 ? (
          <p>Sepetinizde ürün bulunmamaktadır.</p>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-2">
              {cartItems.map(item => (
                <div key={item.id} className="border rounded-lg p-4 mb-4 flex items-center">
                  <img src={item.image} alt={item.name} className="w-16 h-16 object-contain mr-4" />
                  <div className="flex-grow">
                    <h3 className="font-semibold">{item.name}</h3>
                    <p className="text-blue-600 font-bold">{item.price} TL</p>
                  </div>
                  <div className="flex items-center">
                    <button 
                      onClick={() => updateQuantity(item.id, item.quantity - 1)}
                      className="bg-gray-300 text-gray-700 px-3 py-1 rounded-l"
                    >
                      -
                    </button>
                    <span className="bg-gray-200 px-3 py-1">{item.quantity}</span>
                    <button 
                      onClick={() => updateQuantity(item.id, item.quantity + 1)}
                      className="bg-gray-300 text-gray-700 px-3 py-1 rounded-r"
                    >
                      +
                    </button>
                    <button 
                      onClick={() => removeFromCart(item.id)}
                      className="ml-4 bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
                    >
                      Sil
                    </button>
                  </div>
                </div>
              ))}
            </div>
            
            <div className="border rounded-lg p-6 h-fit">
              <h2 className="text-xl font-bold mb-4">Sipariş Özeti</h2>
              <div className="flex justify-between mb-2">
                <span>Ürün Toplamı:</span>
                <span>{getTotalPrice()} TL</span>
              </div>
              <div className="flex justify-between mb-2">
                <span>Kargo:</span>
                <span>Ücretsiz</span>
              </div>
              <hr className="my-4" />
              <div className="flex justify-between font-bold text-lg mb-6">
                <span>Toplam:</span>
                <span>{getTotalPrice()} TL</span>
              </div>
              <button className="w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700">
                Siparişi Tamamla
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Cart;