/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'light': '#DDE6ED',      // Light background
        'subtle': '#9DB2BF',     // Borders, muted text
        'medium': '#526D82',     // Primary text color
        'dark': '#27374D',       // Buttons, active elements, headers
      }
    },
  },
  plugins: [],
}