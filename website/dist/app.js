import { setupI18n, t } from './i18n.js';
import { en, uz } from './locales.js';

// Keep offscreen media lazy and recover a failed local image once.
document.querySelectorAll('img[src]').forEach((image) => {
  image.decoding = 'async';
  const source = new URL(image.getAttribute('src'), document.baseURI);
  if (source.origin !== window.location.origin) return;
  function retry() {
    image.removeEventListener('error', retry);
    source.searchParams.set('retry', '1');
    image.src = source.href;
  }
  image.addEventListener('error', retry);
  if (image.complete && !image.naturalWidth) retry();
});

const i18n = setupI18n({ en, uz });
const menu = document.querySelector('#nav-menu');
const menuButton = document.querySelector('#menu-toggle');
function closeMenu() {
  menu.dataset.open = 'false';
  menuButton.setAttribute('aria-expanded', 'false');
  menuButton.setAttribute('aria-label', t('openMenu'));
}
menuButton.addEventListener('click', () => {
  const open = menu.dataset.open !== 'true';
  menu.dataset.open = String(open);
  menuButton.setAttribute('aria-expanded', String(open));
  menuButton.setAttribute('aria-label', t(open ? 'closeMenu' : 'openMenu'));
});
menu.addEventListener('click', (event) => {
  if (event.target.closest('a')) closeMenu();
});
document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && menu.dataset.open === 'true') {
    closeMenu();
    menuButton.focus();
  }
});
document.addEventListener('click', (event) => {
  if (!event.target.closest('.site-header')) closeMenu();
});

// Keep the visible section discoverable without changing browser history.
if ('IntersectionObserver' in window) {
  const observer = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      for (const link of menu.querySelectorAll('a')) {
        if (link.hash === `#${entry.target.id}`) link.setAttribute('aria-current', 'location');
        else link.removeAttribute('aria-current');
      }
    }
  }, { rootMargin: '-15% 0px -55% 0px' });
  for (const link of menu.querySelectorAll('a[href^="#"]')) {
    const section = document.getElementById(link.hash.slice(1));
    if (section) observer.observe(section);
  }
}

const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
const progress = document.querySelector('.scroll-progress');
let progressFrame = 0;
function updateProgress() {
  if (progressFrame) return;
  progressFrame = requestAnimationFrame(() => {
    progressFrame = 0;
    const { scrollHeight, clientHeight, scrollTop } = document.documentElement;
    const distance = scrollHeight - clientHeight;
    progress.style.setProperty('--scroll-progress', distance > 0 ? scrollTop / distance : 0);
  });
}
window.addEventListener('scroll', updateProgress, { passive: true });
window.addEventListener('resize', updateProgress);
document.addEventListener('portfolio:languagechange', updateProgress);
if ('ResizeObserver' in window) new ResizeObserver(updateProgress).observe(document.body);
updateProgress();

if ('IntersectionObserver' in window && typeof Element.prototype.animate === 'function') {
  const reveals = new Set();
  const revealObserver = new IntersectionObserver((entries) => {
    for (const { target, isIntersecting } of entries) {
      if (!isIntersecting) continue;
      revealObserver.unobserve(target);
      if (reducedMotion.matches || target.matches(':focus-within')) continue;
      const animation = target.animate([
        { opacity: .45, transform: 'translateY(18px)' },
        { opacity: 1, transform: 'translateY(0)' },
      ], { duration: 540, easing: 'cubic-bezier(.2,.75,.25,1)' });
      reveals.add(animation);
      const cancelReveal = () => animation.cancel();
      target.addEventListener('focusin', cancelReveal, { once: true });
      const cleanUp = () => {
        reveals.delete(animation);
        target.removeEventListener('focusin', cancelReveal);
      };
      animation.finished.then(cleanUp, cleanUp);
    }
  }, { threshold: .08 });
  document.querySelectorAll('.scene-panels > *, .section-heading, .project, .timeline-item, .education-item, .certificate-card, .contact-item')
    .forEach((element) => revealObserver.observe(element));
  reducedMotion.addEventListener('change', () => {
    if (!reducedMotion.matches) return;
    for (const animation of reveals) animation.cancel();
  });
}

const sceneVideo = document.querySelector('#scene-video');
const scenePlay = document.querySelector('.scene-play');
const mobileScene = window.matchMedia('(max-width: 600px)');
let sceneVisible = !('IntersectionObserver' in window);
const connection = navigator.connection;
const saveData = () => Boolean(connection?.saveData);
let scenePaused = reducedMotion.matches || saveData();
let sceneReady = false;
let sceneSource;

function updateScene() {
  if (!sceneReady || !sceneVisible || scenePaused || document.hidden) {
    sceneVideo.pause();
    return;
  }
  const source = mobileScene.matches ? sceneVideo.dataset.videoMobile : sceneVideo.dataset.videoDesktop;
  if (source !== sceneSource) {
    sceneSource = source;
    sceneVideo.src = source;
  }
  sceneVideo.play().catch((error) => {
    if (error.name !== 'AbortError' && sceneVideo.paused && sceneVisible && !document.hidden) {
      scenePaused = true;
      updateSceneLabel();
    }
  });
}

function updateSceneLabel() {
  scenePlay.textContent = t(scenePaused ? 'playAnimation' : 'pauseAnimation');
}
scenePlay.hidden = false;
updateSceneLabel();
scenePlay.addEventListener('click', () => {
  sceneReady = true;
  sceneVisible = true;
  scenePaused = !scenePaused;
  updateSceneLabel();
  updateScene();
});
reducedMotion.addEventListener('change', () => {
  scenePaused = reducedMotion.matches || saveData();
  updateSceneLabel();
  updateScene();
});
connection?.addEventListener('change', () => {
  if (!saveData()) return;
  scenePaused = true;
  updateSceneLabel();
  updateScene();
});
mobileScene.addEventListener('change', updateScene);
document.addEventListener('visibilitychange', updateScene);
document.addEventListener('portfolio:languagechange', updateSceneLabel);
if ('IntersectionObserver' in window) {
  new IntersectionObserver(([entry]) => {
    sceneVisible = entry.isIntersecting;
    updateScene();
  }).observe(sceneVideo);
}
function scheduleScene() {
  requestAnimationFrame(() => requestAnimationFrame(() => {
    sceneReady = true;
    updateScene();
  }));
}
if (document.readyState === 'complete') scheduleScene();
else window.addEventListener('load', scheduleScene, { once: true });

const projectGrid = document.querySelector('.project-grid');
const projectControls = document.querySelector('.scene-project-controls');
const projectJumps = document.querySelector('.project-jumps');
const projectLinks = [...projectJumps.querySelectorAll('a')];
const projectCards = projectLinks.map((link) => document.getElementById(link.hash.slice(1)));

function projectOffset(card) {
  const edge = document.documentElement.dir === 'rtl' ? 'right' : 'left';
  return card.getBoundingClientRect()[edge] - projectGrid.getBoundingClientRect()[edge];
}

function openProject(index) {
  projectGrid.scrollBy({
    left: projectOffset(projectCards[index]),
    behavior: reducedMotion.matches ? 'instant' : 'smooth',
  });
}

function visibleProject() {
  return projectCards.reduce((nearest, card, index) =>
    Math.abs(projectOffset(card)) < Math.abs(projectOffset(projectCards[nearest])) ? index : nearest, 0);
}

function updateProjectLinks() {
  const active = visibleProject();
  projectLinks.forEach((link, index) => {
    if (index === active) link.setAttribute('aria-current', 'true');
    else link.removeAttribute('aria-current');
  });
}

projectControls.hidden = false;
projectControls.addEventListener('click', (event) => {
  const button = event.target.closest('[data-project-step]');
  if (!button) return;
  const next = (visibleProject() + Number(button.dataset.projectStep) + projectCards.length) % projectCards.length;
  openProject(next);
});
projectJumps.addEventListener('click', (event) => {
  const link = event.target.closest('a');
  if (!link || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
  event.preventDefault();
  openProject(projectLinks.indexOf(link));
  const bounds = projectGrid.getBoundingClientRect();
  if (bounds.top < 0 && mobileScene.matches) {
    projectGrid.scrollIntoView({ block: 'start', behavior: reducedMotion.matches ? 'instant' : 'smooth' });
  }
});
projectGrid.addEventListener('scroll', updateProjectLinks, { passive: true });
window.addEventListener('resize', updateProjectLinks);
document.addEventListener('portfolio:languagechange', updateProjectLinks);
updateProjectLinks();

let toastTimer;
function notify(message) {
  const toast = document.querySelector('#toast');
  clearTimeout(toastTimer);
  toast.textContent = message;
  toast.hidden = false;
  toastTimer = setTimeout(() => { toast.hidden = true; }, 4500);
}
document.querySelectorAll('[data-copy]').forEach((button) => {
  button.addEventListener('click', async () => {
    try {
      if (!navigator.clipboard?.writeText) throw new Error('Clipboard unavailable');
      await navigator.clipboard.writeText(button.dataset.copy);
      notify(t('copied'));
    } catch {
      notify(t('copyFailed'));
    }
  });
});

const certificate = document.querySelector('#certificate-dialog');
const image = document.querySelector('#certificate-image');
const zoomValue = document.querySelector('#zoom-value');
let zoom = 1;
function changeZoom(value) {
  zoom = Math.min(4, Math.max(1, value));
  image.style.width = `${zoom * 100}%`;
  zoomValue.value = `${Math.round(zoom * 100)}%`;
  document.querySelector('#zoom-out').disabled = zoom <= 1;
  document.querySelector('#zoom-in').disabled = zoom >= 4;
}
document.querySelector('#open-certificate').addEventListener('click', () => {
  changeZoom(1);
  certificate.showModal();
});
document.querySelector('#close-certificate').addEventListener('click', () => certificate.close());
document.querySelector('#zoom-in').addEventListener('click', () => changeZoom(zoom + .25));
document.querySelector('#zoom-out').addEventListener('click', () => changeZoom(zoom - .25));
document.querySelector('#zoom-reset').addEventListener('click', () => changeZoom(1));
certificate.addEventListener('click', (event) => {
  if (event.target !== certificate) return;
  const rect = certificate.getBoundingClientRect();
  if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) certificate.close();
});

document.addEventListener('portfolio:languagechange', () => {
  menuButton.setAttribute('aria-label', t(menu.dataset.open === 'true' ? 'closeMenu' : 'openMenu'));
});
await i18n.ready;
