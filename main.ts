import { Elm } from "/src/Main.elm";
import "/css/app.css";

const app = Elm.Main.init({
  node: document.getElementById("app"),
});

app.ports.openExternalLink.subscribe((externalLink: string) => {
  window.open(externalLink, "_blank").focus();
});
