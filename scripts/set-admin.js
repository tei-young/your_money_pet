#!/usr/bin/env node

/**
 * Firebase Admin Custom Claim 설정 스크립트
 *
 * 사용법:
 *   node scripts/set-admin.js <USER_UID>
 *
 * 예시:
 *   node scripts/set-admin.js abc123xyz456
 */

const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

// Firebase Admin SDK 초기화
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const args = process.argv.slice(2);

if (args.length === 0) {
  console.error('❌ 에러: 사용자 UID를 입력해주세요.');
  console.log('\n사용법: node scripts/set-admin.js <USER_UID>');
  console.log('예시: node scripts/set-admin.js abc123xyz456\n');
  process.exit(1);
}

const userId = args[0];

async function setAdminClaim(uid) {
  try {
    // 사용자 존재 확인
    const user = await admin.auth().getUser(uid);
    console.log(`\n✅ 사용자 찾음: ${user.email}`);

    // admin custom claim 설정
    await admin.auth().setCustomUserClaims(uid, { admin: true });
    console.log(`✅ admin 권한 부여 완료!`);

    // 설정 확인
    const updatedUser = await admin.auth().getUser(uid);
    console.log(`\n📋 Custom Claims:`, updatedUser.customClaims);

    console.log('\n✨ 완료! 사용자가 다시 로그인하면 admin 권한이 적용됩니다.\n');

  } catch (error) {
    console.error('\n❌ 에러 발생:', error.message);
    process.exit(1);
  }
}

setAdminClaim(userId);
