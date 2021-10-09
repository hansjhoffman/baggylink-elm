const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  mode: "jit",
  prefix: "tw-",
  purge: ["index.html", "./src/**/*.{elm,js,ts}"],
  darkMode: true,
  theme: {
    colors: {},
    extend: {},
    fontFamily: {
      // https://fontjoy.com/
      mono: ["DM Mono", ...defaultTheme.fontFamily.mono],
      sans: ["Fira Sans", ...defaultTheme.fontFamily.sans],
      serif: ["Merriweather", ...defaultTheme.fontFamily.serif],
    },
  },
  variants: {
    extend: {},
  },
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/typography")],
};
