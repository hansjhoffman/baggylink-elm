const defaultTheme = require("tailwindcss/defaultTheme");

// https://www.youtube.com/watch?v=MAtaT8BZEAo
const withOpacity =
  (variableName) =>
  ({ opacityValue }) => {
    if (opacityValue !== undefined) {
      return `rgba(var(${variableName}), ${opacityValue})`;
    } else {
      return `rgb(${variableName})`;
    }
  };

module.exports = {
  mode: "jit",
  prefix: "tw-",
  purge: ["index.html", "./src/**/*.{elm,js,ts}"],
  theme: {
    extend: {
      backgroundColor: {
        skin: {
          "african-violet": withOpacity("--color-african-violet"),
          "hot-pink": withOpacity("--color-hot-pink"),
          "maximum-blue": withOpacity("--color-maximum-blue"),
          "raisin-black": withOpacity("--color-raisin-black"),
        },
      },
      borderColor: {
        mustard: withOpacity("--color-mustard"),
      },
      colors: {
        mustard: withOpacity("--color-mustard"),
      },
      dropShadow: {
        "hot-pink": `${withOpacity("--color-hot-pink")({ opacityValue: 1 })} 0px 1px 30px`,
      },
      textColor: {
        skin: {
          base: withOpacity("--color-text-base"),
        },
      },
    },
    fontFamily: {
      // https://www.youtube.com/watch?v=sOnBG2wUm1s
      mono: ["DM Mono", ...defaultTheme.fontFamily.mono],
      sans: ["Poppins", ...defaultTheme.fontFamily.sans],
      serif: ["Lora", ...defaultTheme.fontFamily.serif],
    },
  },
  variants: {
    extend: {},
  },
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/typography")],
};
