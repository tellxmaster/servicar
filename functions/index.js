const functions = require("firebase-functions");
const admin = require("firebase-admin");

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const firestore = admin.firestore();

exports.checkAppointmentsAndCreateReminders = functions.pubsub
    .schedule("0 * * * *") // Ejecutar cada hora
    .onRun(async (context) => {
      const now = admin.firestore.Timestamp.now().toDate();
      const fourHoursFromNow = new Date(now.getTime() + 4 * 60 * 60 * 1000);

      const appointmentsQuery = firestore
          .collection("citas")
          .where("fechaHoraInicio", ">=", now)
          .where("fechaHoraInicio", "<", fourHoursFromNow);

      try {
        const appointmentsSnapshot = await appointmentsQuery.get();

        for (const appointmentDoc of appointmentsSnapshot.docs) {
          const appointmentData = appointmentDoc.data();
          const clientId = appointmentData.idCliente;

          const userDoc = await firestore
              .collection("usuarios")
              .doc(clientId)
              .get();

          if (userDoc.exists) {
            const userEmail = userDoc.data().correo;

            const existingReminder = await firestore
                .collection("mail")
                .where("appointmentId", "==", appointmentDoc.id)
                .get();

            if (existingReminder.empty) {
              const reminder = {
                appointmentId: appointmentDoc.id,
                userEmail: userEmail,
                sentAt: admin.firestore.Timestamp.now(),
              };

              await firestore.collection("mail").add(reminder);
              console.log(
                `Recordatorio de correo electrónico creado para la cita ${appointmentData.idCita}`
              );
            }
          }
        }
      } catch (error) {
        console.error("Error: ", error);
      }
    });
