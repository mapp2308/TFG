const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentDeleted } = require("firebase-functions/v2/firestore");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

// ✅ FUNCION 1: Notificación diaria si un evento es en 2 días
exports.dailyEventReminder = onSchedule(
  {
    schedule: "5 14 * * *", // Todos los días a las 14:05
    timeZone: "Europe/Madrid",
  },
  async (event) => {
    const now = admin.firestore.Timestamp.now();
    const inTwoDays = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 2 * 24 * 60 * 60 * 1000)
    );

    const eventosSnap = await db
      .collection("eventos")
      .where("fecha", ">=", now)
      .where("fecha", "<=", inTwoDays)
      .get();

    if (eventosSnap.empty) return;

    const eventos = eventosSnap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    const usuariosSnap = await db.collection("usuarios").get();

    for (const usuario of usuariosSnap.docs) {
      const data = usuario.data();
      const token = data.fcmToken;
      const asistir = data.asistir || [];

      const eventosUsuario = eventos.filter((ev) => asistir.includes(ev.id));

      for (const evento of eventosUsuario) {
        try {
          await admin.messaging().send({
            token,
            notification: {
              title: "📅 Recordatorio de evento",
              body: `Recuerda que el evento '${evento.nombre}' es en menos de 2 días.`,
            },
          });
        } catch (error) {
          console.error(`❌ Error enviando a ${token}:`, error);
        }
      }
    }
  }
);

// ✅ FUNCION 2: Notificación si se elimina un evento al que alguien asistiría
exports.notifyEventDeletion = onDocumentDeleted(
  "eventos/{eventoId}",
  async (event) => {
    const deletedEvent = event.data?.data();
    const eventId = event.params.eventoId;

    if (!deletedEvent || !eventId) return;

    const nombre = deletedEvent.nombre || "un evento";

    const usuariosSnap = await db.collection("usuarios").get();

    for (const doc of usuariosSnap.docs) {
      const data = doc.data();
      const asistir = data.asistir || [];
      const token = data.fcmToken;

      if (asistir.includes(eventId) && token) {
        try {
          await admin.messaging().send({
            token,
            notification: {
              title: "❌ Evento cancelado",
              body: `El evento '${nombre}' al que ibas a asistir ha sido cancelado.`,
            },
          });
        } catch (error) {
          console.error(`Error al enviar a ${token}:`, error);
        }
      }
    }
  }
);
