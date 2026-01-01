#!/usr/bin/env node

/**
 * Firestore 초기 데이터 설정 스크립트
 *
 * 사용법:
 *   node scripts/init-firestore.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

// Firebase Admin SDK 초기화
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function initializeFirestore() {
  console.log('\n🚀 Firestore 초기화 시작...\n');

  try {
    // 1. App Config 생성
    console.log('📝 App Config 생성 중...');
    await db.collection('app_config').doc('config').set({
      minAppVersion: '1.0.0',
      forceUpdateVersion: '1.0.0',
      maintenanceMode: false,
      maintenanceMessage: null,
      features: {
        characterSelection: true,
        dailyReminder: true,
        sharing: true
      },
      constants: {
        totalDays: 365,
        learningPoints: 50,
        quizPointsPerQuestion: 20
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'admin'
    });
    console.log('✅ App Config 생성 완료\n');

    // 2. Character Configs 생성
    console.log('📝 Character Configs 생성 중...');

    const characters = [
      {
        characterId: 'money_bear',
        personalityType: 'safe',
        displayName: '머니베어',
        fullName: 'Money Bear 머니베어',
        description: '든든하게 지키는',
        emoji: '🐻',
        colorHex: '#718096',
        dialogues: {
          intro: '안전하게 함께 시작해요! 🐻',
          quizGreeting: '함께 성향을 알아볼까요?',
          resultMatch: '우리 딱 맞는 것 같아요!',
          resultDifferent: '이런 성향도 좋아요!'
        },
        curriculum: '예적금의 기본과 복리의 힘부터 시작해요',
        isActive: true,
        sortOrder: 1,
        version: '1.0',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        characterId: 'save_sheep',
        personalityType: 'balanced',
        displayName: '세이브쉽',
        fullName: 'Save Sheep 세이브쉽',
        description: '균형있게 키우는',
        emoji: '🐑',
        colorHex: '#B794F6',
        dialogues: {
          intro: '균형잡힌 시작, 함께해요! 🐑',
          quizGreeting: '성향을 알아볼까요?',
          resultMatch: '완벽한 조합이네요!',
          resultDifferent: '새로운 도전도 좋아요!'
        },
        curriculum: '저축과 투자의 균형을 배워요',
        isActive: true,
        sortOrder: 2,
        version: '1.0',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        characterId: 'hunter_cat',
        personalityType: 'aggressive',
        displayName: '헌터캣',
        fullName: 'Hunter Cat 헌터캣',
        description: '적극적으로 늘리는',
        emoji: '🐱',
        colorHex: '#9F7AEA',
        dialogues: {
          intro: '기회를 잡으러 가요! 🐱',
          quizGreeting: '함께 알아볼까요?',
          resultMatch: '우리 환상의 팀이에요!',
          resultDifferent: '다른 방법도 멋져요!'
        },
        curriculum: '주식과 투자 전략을 배워요',
        isActive: true,
        sortOrder: 3,
        version: '1.0',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        characterId: 'chaser_fox',
        personalityType: 'challenger',
        displayName: '체이서폭스',
        fullName: 'Chaser Fox 체이서폭스',
        description: '과감하게 도전하는',
        emoji: '🦊',
        colorHex: '#4A5568',
        dialogues: {
          intro: '도전의 시작, 함께해요! 🦊',
          quizGreeting: '성향을 파악해볼까요?',
          resultMatch: '완벽한 파트너네요!',
          resultDifferent: '새로운 길도 재미있어요!'
        },
        curriculum: '고수익 투자와 리스크 관리를 배워요',
        isActive: true,
        sortOrder: 4,
        version: '1.0',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }
    ];

    for (const character of characters) {
      await db.collection('character_configs').doc(character.characterId).set(character);
      console.log(`  ✅ ${character.displayName} (${character.characterId})`);
    }
    console.log('✅ Character Configs 생성 완료\n');

    // 3. 샘플 Learning Content 생성
    console.log('📝 샘플 Learning Content 생성 중...');

    const sampleLearningContent = {
      contentId: 'day_001_safe',
      day: 1,
      personalityType: 'safe',
      title: '예적금의 기본',
      cards: [
        {
          order: 1,
          type: 'text',
          content: '안녕하세요! 오늘은 예금과 적금의 차이에 대해 알아볼게요.',
          imageUrl: null
        },
        {
          order: 2,
          type: 'text',
          content: '**예금**은 자유롭게 입출금이 가능한 통장이에요. 필요할 때 언제든 찾을 수 있어요.',
          imageUrl: null
        },
        {
          order: 3,
          type: 'text',
          content: '**적금**은 매달 정해진 금액을 넣고, 만기까지 찾을 수 없어요. 대신 이자가 더 높죠!',
          imageUrl: null
        }
      ],
      estimatedMinutes: 3,
      points: 50,
      isPublished: true,
      version: '1.0',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: 'admin',
      tags: ['예금', '적금', '기본']
    };

    await db.collection('learning_contents').doc('day_001_safe').set(sampleLearningContent);
    console.log('  ✅ Day 1 - 안전형 학습 콘텐츠');
    console.log('✅ 샘플 Learning Content 생성 완료\n');

    // 4. 샘플 Quiz Content 생성
    console.log('📝 샘플 Quiz Content 생성 중...');

    const sampleQuizContent = {
      quizId: 'day_001_safe_quiz',
      day: 1,
      personalityType: 'safe',
      questions: [
        {
          order: 1,
          question: '예금과 적금의 가장 큰 차이는 무엇일까요?',
          options: [
            {
              text: '자유롭게 입출금할 수 있는지',
              isCorrect: true,
              explanation: '맞습니다! 예금은 자유입출금, 적금은 정기적립이에요.'
            },
            {
              text: '이자율',
              isCorrect: false,
              explanation: '이자율도 차이가 있지만, 가장 큰 차이는 입출금 방식이에요.'
            },
            {
              text: '최소 가입금액',
              isCorrect: false,
              explanation: '최소 가입금액은 상품마다 다르지만, 핵심 차이는 아니에요.'
            }
          ],
          points: 50
        },
        {
          order: 2,
          question: '다음 중 적금의 장점은 무엇일까요?',
          options: [
            {
              text: '언제든 돈을 찾을 수 있다',
              isCorrect: false,
              explanation: '적금은 만기까지 찾을 수 없어요. 이건 예금의 특징이죠.'
            },
            {
              text: '높은 이자율',
              isCorrect: true,
              explanation: '맞습니다! 적금은 예금보다 이자율이 높은 편이에요.'
            },
            {
              text: '가입 절차가 간단하다',
              isCorrect: false,
              explanation: '가입 절차는 예금과 비슷해요.'
            }
          ],
          points: 50
        }
      ],
      totalPoints: 100,
      passingScore: 60,
      isPublished: true,
      version: '1.0',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: 'admin'
    };

    await db.collection('quiz_contents').doc('day_001_safe_quiz').set(sampleQuizContent);
    console.log('  ✅ Day 1 - 안전형 퀴즈');
    console.log('✅ 샘플 Quiz Content 생성 완료\n');

    console.log('🎉 Firestore 초기화 완료!\n');
    console.log('📊 생성된 데이터:');
    console.log('  - app_config: 1개');
    console.log('  - character_configs: 4개');
    console.log('  - learning_contents: 1개 (샘플)');
    console.log('  - quiz_contents: 1개 (샘플)\n');

  } catch (error) {
    console.error('\n❌ 에러 발생:', error);
    process.exit(1);
  }

  process.exit(0);
}

initializeFirestore();
