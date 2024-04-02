const colors = require("tailwindcss/colors");
const fs = require("fs");
const plugin = require("tailwindcss/plugin");
const path = require("path");

module.exports = {
  mode: "jit",
  content: [
    "./js/**/*.js",
    "../lib/*_web/**/*.*ex",
    "../lib/ash_hq/docs/extensions/**/*.*ex",
    "../priv/blog/**/*.md",
    "../deps/ash_authentication_phoenix/**/*.ex",
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
      colors: require("./tailwind.colors.json"),
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
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized");
      let values = {};
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
      ];
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map((file) => {
          let name = path.basename(file, ".svg") + suffix;
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
        });
      });
      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            let content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, "");
            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              "-webkit-mask": `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              "mask-repeat": "no-repeat",
              "background-color": "currentColor",
              "vertical-align": "middle",
              display: "inline-block",
              width: theme("spacing.5"),
              height: theme("spacing.5"),
            };
          },
        },
        { values },
      );
    }),
  ],
  safelist: [
    // Used in Table of Contents generation, which is stored in the DB and cannot be
    // checked at build time.
    "m-0",
    "ml-0.5",
    "mr-1",
    "md:w-[20em]",
    "md:p-4",
    "md:float-right",
    "list-[lower-alpha]",
    "md:border",
    "md:border-base-light-300",
    "md:dark:border-base-dark-600",
    "md:ml-8",
    "md:mb-8",
    "text-ellipsis",
    "overflow-hidden",
  ],
};
