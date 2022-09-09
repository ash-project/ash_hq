const colors = require("tailwindcss/colors");

module.exports = {
  mode: "jit",
  content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  darkMode: "class",
  theme: {
    extend: {
      typography: {
        DEFAULT: {
          css: {
            "code::before": {
              content: '""',
            },
            "code::after": {
              content: '""',
            },
          },
        },
      },
      backgroundImage: {
        "dark-grid": `linear-gradient(to bottom, rgb(24, 25, 32, 80%) 20%, rgb(24, 25, 32, 50%) 40%, rgb(24, 25, 32, 40%) 80%, rgb(24, 25, 32, 60%) 20%), url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ada3bf' fill-opacity='0.26'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
        "light-grid": `linear-gradient(to bottom, rgb(255, 255, 255, 90%) 20%, rgb(255, 255, 255, 85%) 30%, rgb(255, 255, 255, 80%) 80%,  rgb(255, 255, 255, 95%) 20%), url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23312a3b' fill-opacity='0.42'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");`,
      },
      colors: {
        "silver-phoenix": "#EAEBF3",
        "base-dark": {
          DEFAULT: "#5E627D",
          50: "#C2C4D1",
          100: "#B6B8C8",
          200: "#9FA2B7",
          300: "#878BA5",
          400: "#707594",
          500: "#5E627D",
          600: "#46495D",
          700: "#2E303D",
          800: "#16171D",
          900: "#000000",
        },
        "base-light": {
          50: "#f9fafb",
          100: "#f3f4f6",
          200: "#e5e7eb",
          300: "#d1d5db",
          400: "#9ca3af",
          500: "#6b7280",
          600: "#4b5563",
          700: "#374151",
          800: "#1f2937",
          900: "#111827",
        },
        "primary-dark": {
          DEFAULT: "#FF5757",
          50: "#FFE1E1",
          100: "#FFD1D1",
          200: "#FFB3B3",
          300: "#FF9494",
          400: "#FF7676",
          500: "#FF5757",
          600: "#FF1F1F",
          700: "#E60000",
          800: "#AE0000",
          900: "#760000",
        },
        "primary-light": {
          DEFAULT: "#FF914D",
          50: "#FFE6D7",
          100: "#FFDDC7",
          200: "#FFCAA9",
          300: "#FFB78A",
          400: "#FFA46C",
          500: "#FF914D",
          600: "#FF6E15",
          700: "#DC5400",
          800: "#A43F00",
          900: "#6C2900",
        },
      },
    },
  },
  variants: {
    extend: {
      display: ["dark"],
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
  ],
};
