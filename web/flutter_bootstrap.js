{{flutter_js}}
{{flutter_build_config}}

// Keep renderer files on the same origin in debug and release builds.
const startupConfig = {
  canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).toString(),
};
const startup = document.getElementById('startup');
let firstFrame = false;
window.addEventListener('flutter-first-frame', () => {
  firstFrame = true;
  startup?.remove();
});
function showStartupError(error) {
  console.error('Campus Assistant startup failed:', error);
  if (firstFrame || !startup) return;
  const status = document.getElementById('startup-status');
  if (status) status.textContent = 'Не удалось открыть приложение. Повторите загрузку.';
  document.getElementById('startup-progress')?.remove();
  const retry = document.getElementById('startup-retry');
  if (retry) retry.hidden = false;
}
window.addEventListener('error', event => showStartupError(event.error ?? event.message));
window.addEventListener('unhandledrejection', event => showStartupError(event.reason));
_flutter.loader.load({
  config: startupConfig,
  onEntrypointLoaded: async engineInitializer => {
    try {
      const appRunner = await engineInitializer.initializeEngine(startupConfig);
      await appRunner.runApp();
    } catch (error) {
      showStartupError(error);
    }
  },
}).catch(showStartupError);
