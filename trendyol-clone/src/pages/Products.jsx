import React from 'react';
import { Link } from 'react-router-dom';

const Products = () => {
  // Mock ürün verileri
  const products = [
    { id: 1, name: 'Gömlek', price: 149.99, image: 'https://via.placeholder.com/200x200?text=Gömlek' },
    { id: 2, name: 'Pantolon', price: 249.99, image: 'https://via.placeholder.com/200x200?text=Pantolon' },
    { id: 3, name: 'Ayakkabı', price: 349.99, image: 'https://via.placeholder.com/200x200?text=Ayakkabı' },
    { id: 4, name: 'Ceket', price: 499.99, image: 'https://via.placeholder.com/200x200?text=Ceket' },
    { id: 5, name: 'Eldiven', price: 49.99, image: 'https://via.placeholder.com/200x200?text=Eldiven' },
    { id: 6, name: 'Şapka', price: 39.99, image: 'https://via.placeholder.com/200x200?text=Şapka' },
  ];

  return (
    <div className="products-page py-8">
      <div className="container mx-auto">
        <h1 className="text-3xl font-bold mb-6">Tüm Ürünler</h1>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {products.map((product) => (
            <div key={product.id} className="border rounded-lg p-4 hover:shadow-lg transition-shadow">
              <Link to={`/product/${product.id}`}>
                <img src={product.image} alt={product.name} className="w-full h-48 object-contain" />
                <h3 className="font-semibold mt-2">{product.name}</h3>
                <p className="text-blue-600 font-bold">{product.price} TL</p>
              </Link>
              <button className="mt-2 bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 w-full">
                Sepete Ekle
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Products;