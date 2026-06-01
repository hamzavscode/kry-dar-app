# TODO - Publier maison: transfert BDD + upload images

## Étapes
- [ ] 1) Ajouter un état `isPublishing` + try/catch dans `AddHouseScreen._publish()` pour afficher les erreurs (Cloudinary/Firestore) à l’écran.
- [ ] 2) Refaire un test manuel: sélectionner images -> vérifier preview, puis cliquer « Publier » et relever le message d’erreur.
- [ ] 3) En fonction de l’erreur Cloudinary: corriger la logique d’upload dans `CloudinaryService` (preset/signature/paramètres).
- [ ] 4) Vérifier que les champs Firestore correspondent à ce que l’UI attend (noms des clés image/ville/quartier, etc.).

