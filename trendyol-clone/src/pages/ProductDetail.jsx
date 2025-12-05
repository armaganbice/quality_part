import React, { useState } from 'react';
import { useParams } from 'react-router-dom';

const ProductDetail = () => {
  const { id } = useParams();
  
  // Mock ürün detay verisi
  const product = {
    id: parseInt(id),
    name: `Ürün ${id}`,
    description: `Bu ${id}. ürünün açıklamasıdır. Kaliteli malzemelerden üretilmiştir.`,
    price: 199.99 + (parseInt(id) * 10),
    image: `https://via.placeholder.com/400x400?text=Ürün+${id}`,
    rating: 4.5,
    stock: 10
  };

  const [quantity, setQuantity] = useState(1);

  const handleAddToCart = () => {
    alert(`${product.name} sepete eklendi!`);
  };

  return (
    <div className="product-detail-page py-8">
      <div className="container mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div className="image-section">
            <img src={product.image} alt={product.name} className="w-full h-auto" />
          </div>
          
          <div className="info-section">
            <h1 className="text-3xl font-bold mb-2">{product.name}</h1>
            <div className="rating mb-4">
              <span className="text-yellow-500">★</span>
              <span className="ml-1">{product.rating} (123 değerlendirme)</span>
            </div>
            <p className="text-2xl text-blue-600 font-bold mb-4">{product.price} TL</p>
            
            <div className="mb-6">
              <h3 className="font-semibold text-lg mb-2">Ürün Açıklaması</h3>
              <p>{product.description}</p>
            </div>
            
            <div className="mb-6">
              <label className="block mb-2">Adet:</label>
              <select 
                value={quantity} 
                onChange={(e) => setQuantity(parseInt(e.target.value))}
                className="border rounded p-2 mr-2"
              >
                {[...Array(Math.min(product.stock, 10)).keys()].map(num => (
                  <option key={num+1} value={num+1}>{num+1}</option>
                ))}
              </select>
              <span>Stokta {product.stock} adet var</span>
            </div>
            
            <div className="actions">
              <button 
                onClick={handleAddToCart}
                className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 mr-4"
              >
                Sepete Ekle
              </button>
              <button className="bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700">
                Hemen Al
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProductDetail;