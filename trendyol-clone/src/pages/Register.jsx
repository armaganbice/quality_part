import React, { useState } from 'react';
import { Link } from 'react-router-dom';

const Register = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Kayıt bilgileri:', { name, email, password });
    alert('Kayıt başarılı!');
  };

  return (
    <div className="register-page py-8">
      <div className="container mx-auto max-w-md">
        <h1 className="text-3xl font-bold mb-6 text-center">Kayıt Ol</h1>
        
        <form onSubmit={handleSubmit} className="border rounded-lg p-6">
          <div className="mb-4">
            <label className="block mb-2">Ad Soyad:</label>
            <input 
              type="text" 
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full border rounded p-2"
              required 
            />
          </div>
          
          <div className="mb-4">
            <label className="block mb-2">E-posta:</label>
            <input 
              type="email" 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full border rounded p-2"
              required 
            />
          </div>
          
          <div className="mb-6">
            <label className="block mb-2">Şifre:</label>
            <input 
              type="password" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full border rounded p-2"
              required 
            />
          </div>
          
          <button type="submit" className="w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700">
            Kayıt Ol
          </button>
          
          <div className="mt-4 text-center">
            <p>Zaten hesabınız var mı? <Link to="/login" className="text-blue-600">Giriş Yap</Link></p>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Register;