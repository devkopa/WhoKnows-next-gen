import Image from "next/image";

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8 gap-12 font-sans bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
      
      {/* Hero Section */}
      <header className="flex flex-col items-center gap-4 text-center">
        <h1 className="text-4xl sm:text-5xl font-bold">Innovate Your Future</h1>
        <p className="text-lg sm:text-xl max-w-xl">
          Explore our services, learn more about our mission, and discover how we can help you achieve your goals.
        </p>
        <Image
          src="/logo.png" // Replace with your logo
          alt="Company Logo"
          width={120}
          height={120}
          className="mt-4"
        />
      </header>

      {/* Features / Sections */}
      <main className="grid sm:grid-cols-2 lg:grid-cols-3 gap-8 max-w-6xl w-full">
        <section className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow hover:shadow-lg transition">
          <h2 className="text-2xl font-semibold mb-2">About Us</h2>
          <p>We specialize in creating solutions that help businesses grow and individuals succeed.</p>
        </section>
        <section className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow hover:shadow-lg transition">
          <h2 className="text-2xl font-semibold mb-2">Services</h2>
          <p>From consulting to development, we offer a wide range of services tailored to your needs.</p>
        </section>
        <section className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow hover:shadow-lg transition">
          <h2 className="text-2xl font-semibold mb-2">Contact</h2>
          <p>Reach out via email or social media to start your project or ask questions.</p>
        </section>
      </main>

      {/* Footer */}
      <footer className="mt-12 text-center text-sm text-gray-500 dark:text-gray-400">
        &copy; {new Date().getFullYear()} Innovate Co. All rights reserved.
      </footer>
    </div>
  );
}