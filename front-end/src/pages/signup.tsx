"use client";
import { useState } from "react";
import { signup } from "../firebase/auth";
import { useRouter } from "next/navigation";
import Image from "next/image";
import "../app/globals.css";
import { User } from "firebase/auth";

const Signup = () => {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [address, setAddress] = useState("");
  const [phone, setPhone] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();

  const handleSignup = async () => {
    try {
      const userId = await signup({ name, email, password, address, phone });
      await saveUserRole(userId, "user"); // Ensure the role is stored
      router.push("/dashboard");
    } catch (err: any) {
      setError(err.message);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-50">
      <div className="w-full max-w-md bg-white p-8 rounded-lg shadow-lg">
        {/* Logo */}
        <div className="flex justify-center mb-4">
          <Image src="/logo.webp" alt="Logo" width={40} height={40} />
        </div>

        {/* Title */}
        <h2 className="text-2xl font-bold text-center mb-6">Create an account</h2>

        {/* Input Fields */}
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700">Full Name</label>
          <input
            type="text"
            placeholder="Enter your name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="mt-1 w-full p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700">Email Address</label>
          <input
            type="email"
            placeholder="Enter your email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="mt-1 w-full p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700">Password</label>
          <input
            type="password"
            placeholder="Create a password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="mt-1 w-full p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700">Phone Number</label>
          <input
            type="tel"
            placeholder="Enter your phone number"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            className="mt-1 w-full p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700">Address</label>
          <input
            type="text"
            placeholder="Enter your address"
            value={address}
            onChange={(e) => setAddress(e.target.value)}
            className="mt-1 w-full p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        {/* Sign Up Button */}
        <button
          onClick={handleSignup}
          className="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700 transition"
        >
          Sign Up
        </button>

        {/* Error Message */}
        {error && <p className="text-red-500 text-sm text-center mt-4">{error}</p>}
      </div>
    </div>
  );
};

export default Signup;
function saveUserRole(userId: User, arg1: string) {
  throw new Error("Function not implemented.");
}

