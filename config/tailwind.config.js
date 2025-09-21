// config/tailwind.config.js
const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./app/views/**/*.{html,erb}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/assets/stylesheets/**/*.css",
  ],
  theme: {
    extend: {
      colors: {
        ...defaultTheme.colors, // include all default Tailwind colors
      },
    },
  },
  plugins: [],
};