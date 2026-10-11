# 🏋️ FitStart - Beginner Fitness & Home Workout Mobile App

Welcome to the official repository for **FitStart**, developed as part of the **IT3060 Human-Computer Interaction (HCI) Group Project**. 

FitStart is a mobile application designed specifically for fitness beginners to seamlessly perform home workouts, track daily progress, and stay motivated through structured guidance and AI-powered recommendations.

---

## 📱 Project Overview
* **Project Name:** FitStart
* **Domain:** Health & Fitness / Mobile Application
* **Module:** IT3060 - HCI 

---

## 👥 Group Members
* **Nethmi P.P.U.** 
* **Y.K.M.V.S.** 
* **Abeyrathna Bandara** 
* **Matheews Janoshan H.B.K.D. Bandara** 

---

## 🔐 Firebase expert support setup

FitStart uses `users/{uid}` as the authoritative account/approval record and `expert_directory/{uid}` as the public profile document. Both IDs must be the expert's Firebase Authentication UID. The directory contains only public profile fields. Firestore rules require the query to filter for `isApproved == true` and a supported role; expert profile writes are authorized against the matching approved `users/{uid}` record. These query rules intentionally check the public directory document itself so Firestore can prove the filtered list query is safe. No Cloud Function or Blaze plan is required.

### Deploy Firestore configuration

The default Firebase project is `fitstart-dc5bd`.

```bash
firebase deploy --only firestore
```

This publishes the checked-in Firestore security rules and the `expert_directory` query index. No Cloud Functions deployment or billing-plan upgrade is needed.

### Expert profile records

Each expert must have a `users/{Firebase-Auth-UID}` document with `role` equal to `coach` or `therapist` and `isApproved` equal to boolean `true`. The first time the approved expert opens the Expert Dashboard, the app copies only their public profile fields into `expert_directory/{same UID}`. Rules allow this write only to that same signed-in, approved expert. Profile edits from the app update the public document too. When an administrator revokes approval or changes an expert's role, also delete `expert_directory/{uid}` in the Console so the public listing is removed; without Cloud Functions, that denormalized public record is not automatically deleted.

If an expert has not signed into the dashboard yet, an administrator can create `expert_directory/{Firebase-Auth-UID}` manually in Firebase Console → **Firestore Database → Data → Start collection / Add document**. Use the exact UID as the document ID and these fields/types:

- `name` — string; expert's public name
- `role` — string; `coach` or `therapist`, matching `users/{uid}.role`
- `specialization` — string
- `bio` — string (may be empty)
- `photoUrl` — string (may be empty)
- `experience` — integer (0 or more)
- `isAvailable` — boolean (or null if not specified)
- `isApproved` — boolean `true`
- `updatedAt` — Firestore timestamp

Do not copy email or other private fields into the public directory. The app queries this collection directly and only displays approved coach/therapist records. Approval is still checked against the private `users/{uid}` record by Firestore rules, so a public document alone cannot make an account an expert.

### Verify user-to-expert messaging

1. Deploy Firestore rules/indexes, then sign in as each coach/therapist once and open the Expert Dashboard (or add that expert's public directory document manually).
2. Sign in as a member and open **Support**. Approved experts should appear in separate Fitness Coaches and Therapists sections.
3. Tap **Message**, send a message, then sign in as that expert and reply from the live inbox. Verify both clients receive updates in real time.
4. Verify an unrelated signed-in account cannot read the conversation.

Messaging reuses the existing participant-restricted `support_chats/{chatId}/messages` schema. The separate support-request/reply flow remains available.

---
© 2026 FitStart Team. All rights reserved.
