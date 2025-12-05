import React, { useState } from 'react';
import { Link } from 'react-router-dom';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Giriş bilgileri:', { email, password });
    alert('Giriş başarılı!');
  };

  return (
    <div className="login-page py-8">
      <div className="container mx-auto max-w-md">
        <h1 className="text-3xl font-bold mb-6 text-center">Giriş Yap</h1>
        
        <form onSubmit={handleSubmit} className="border rounded-lg p-6">
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
            Giriş Yap
          </button>
          
          <div className="mt-4 text-center">
            <p>Hesabınız yok mu? <Link to="/register" className="text-blue-600">Kayıt Ol</Link></p>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Login;