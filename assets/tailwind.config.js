const colors = require('tailwindcss/colors')

module.exports = {
  mode: "jit",
  purge: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  darkMode: "class",
  theme: {
    extend: {
      backgroundImage: {
        'dark-grid': `linear-gradient(to bottom, rgb(24, 25, 32, 80%) 20%, rgb(24, 25, 32, 50%) 40%, rgb(24, 25, 32, 40%) 80%, rgb(24, 25, 32, 60%) 20%), url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ada3bf' fill-opacity='0.26'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
        'light-grid': `linear-gradient(to bottom, rgb(255, 255, 255, 90%) 20%, rgb(255, 255, 255, 85%) 30%, rgb(255, 255, 255, 80%) 80%,  rgb(255, 255, 255, 95%) 20%), url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23312a3b' fill-opacity='0.42'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");`
      },
      colors: {
        'primary-black': '#181920',
        'silver-phoenix': '#EAEBF3'
      },
    },
  },
  variants: {
    extend: {
      display: ['dark']
    },
  },
  plugins: [],
};

