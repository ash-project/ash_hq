const colors = require("tailwindcss/colors");

module.exports = {
  mode: "jit",
  content: [
    "./js/**/*.js", 
    "../lib/*_web/**/*.*ex", 
    "../deps/sunflower_ui/**/*.ex", 
    "../priv/blog/**/*.md", 
    "../deps/ash_authentication_phoenix/**/*.ex"
  ],
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
      colors: require("./tailwind.colors.json")
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
