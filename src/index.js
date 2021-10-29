import { initializeApp } from "firebase/app";
import { getAuth, signInWithPopup, signOut, GoogleAuthProvider, onAuthStateChanged } from "firebase/auth";
import { getAnalytics } from "firebase/analytics";

import registerServiceWorker from "./registerServiceWorker";

const firebaseConfig = {
  apiKey: "AIzaSyBnYcdSyezoIY7QajrQYesvngKhvQZVCeU",
  authDomain: "ninedotslabs-be.firebaseapp.com",
  projectId: "ninedotslabs-be",
  storageBucket: "ninedotslabs-be.appspot.com",
  messagingSenderId: "629009108645",
  appId: "1:629009108645:web:deb4a970866b528714474c",
  measurementId: "G-R3SHWM872B"
};

const firebaseApp = initializeApp(firebaseConfig);
const provider = new GoogleAuthProvider();
const auth = getAuth();
const analytics = getAnalytics(firebaseApp);

const app = Elm.Main.init({
  node: document.getElementById("root")
});

app.ports.signIn.subscribe(() => {
  console.log("LogIn called");
  signInWithPopup(auth, provider)
    .then(result => {
      result.user.getIdToken().then(idToken => {
        app.ports.signInInfo.send({
          token: idToken,
          email: result.user.email,
          uid: result.user.uid
        });
      });
    })
    .catch(error => {
      app.ports.signInError.send({
        code: error.code,
        message: error.message
      });
    });
});

app.ports.signOut.subscribe(() => {
  console.log("LogOut called");
  signOut(auth);
});

