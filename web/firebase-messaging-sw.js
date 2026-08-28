importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBBLZRiV0FcVu8QhPFCwA9hcLQnJuXwDTI",
  appId: "1:241485351877:web:cd27ae67e66a74e52019ac",
  messagingSenderId: "241485351877",
  projectId: "wallet-admin-c7100",
  authDomain: "wallet-admin-c7100.firebaseapp.com",
  storageBucket: "wallet-admin-c7100.firebasestorage.app",
  measurementId: "G-FKNJHGMWD9"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  self.registration.showNotification(notification.title || "Wallet update", {
    body: notification.body || "",
    icon: "/icons/Icon-192.png"
  });
});
