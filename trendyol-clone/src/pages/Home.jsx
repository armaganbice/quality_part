import React from 'react';
import { Link } from 'react-router-dom';

const Home = () => {
  return (
    <div className="home-page">
      <section className="hero bg-blue-100 p-8">
        <div className="container mx-auto text-center">
          <h1 className="text-3xl font-bold mb-4">Hoş Geldiniz!</h1>
          <p className="text-lg mb-6">En yeni trend ürünler burada</p>
          <Link to="/products" className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700">
            Alışverişe Başla
          </Link>
        </div>
      </section>

      <section className="featured-products py-8">
        <div className="container mx-auto">
          <h2 className="text-2xl font-bold mb-6">Öne Çıkan Ürünler</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
            {[1, 2, 3, 4].map((item) => (
              <div key={item} className="border rounded-lg p-4 hover:shadow-lg transition-shadow">
                <img src={`https://via.placeholder.com/200x200?text=Ürün+${item}`} alt={`Ürün ${item}`} className="w-full h-48 object-contain" />
                <h3 className="font-semibold mt-2">Ürün {item}</h3>
                <p className="text-blue-600 font-bold">199,99 TL</p>
                <button className="mt-2 bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 w-full">
                  Sepete Ekle
                </button>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;