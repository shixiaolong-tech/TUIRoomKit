<template>
  <div class="chat-container">
    <TUIChat />
  </div>
</template>

<script setup lang="ts">
import { defineAsyncComponent, onMounted } from 'vue';
import { TUIConversationService } from '@tencentcloud/chat-uikit-engine';
import Server from '../ChatKit/server';
import { roomService, Theme, LanguageOption } from '../../../services';
import { hideTUIChatFeatures } from '../ChatKit/components/TUIChat/config';
import TUIChatServer from '../ChatKit/components/TUIChat/server';

import { useBasicStore } from '../../../stores/basic';
import { useUIKit } from '@tencentcloud/uikit-base-component-vue3';

const { theme, setTheme } = useUIKit();

const TUIChat = defineAsyncComponent(
  () => import('../ChatKit/components/TUIChat/index.vue')
);

const basicStore = useBasicStore();

const defaultHideFeaturesButtons = [
  'InputFace',
  'InputStickers',
  'InputVoice',
  'InputEvaluation',
  'InputQuickReplies',
  'InputMention',
  'QuoteMessage',
  'ForwardMessage',
  'TranslateMessage',
  'VoiceToText',
  'EmojiReaction',
  'MultiSelection',
  'MessageSearch',
  'ReadStatus',
];

const currentRoomId = `GROUP${basicStore.roomId}`;

const chatKitServer = new Server();
chatKitServer.init();
new TUIChatServer();

TUIConversationService.switchConversation(currentRoomId);
hideTUIChatFeatures(defaultHideFeaturesButtons);
roomService.setLanguage(basicStore.lang as LanguageOption);

onMounted(() => {
  theme.value
    ? setTheme(theme.value)
    : roomService.setTheme(basicStore.defaultTheme as Theme);
});
</script>

<style lang="scss" scoped>
.chat-container {
  width: 100%;
  height: 100%;
}

.chat-container-chat-scene {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 20px;
}
</style>
