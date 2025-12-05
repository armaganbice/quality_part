import React from 'react';
import { Link } from 'react-router-dom';

const Header = () => {
  return (
    <header className="bg-blue-600 text-white p-4">
      <div className="container mx-auto flex justify-between items-center">
        <div className="logo">
          <Link to="/" className="text-xl font-bold">Trendyol Clone</Link>
        </div>
        <nav className="nav-menu">
          <ul className="flex space-x-4">
            <li><Link to="/">Ana Sayfa</Link></li>
            <li><Link to="/products">Ürünler</Link></li>
            <li><Link to="/cart">Sepet (0)</Link></li>
          </ul>
        </nav>
        <div className="auth-buttons">
          <Link to="/login" className="mr-2">Giriş</Link>
          <Link to="/register">Kayıt</Link>
        </div>
      </div>
    </header>
  );
};

export default Header;