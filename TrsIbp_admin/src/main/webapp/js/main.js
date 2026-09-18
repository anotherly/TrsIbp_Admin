/* ======================================================
   NEXORA Corporate Website - Main JavaScript
   ES5 Compatible (전자정부프레임워크 3.9 호환)
   ====================================================== */

/* ── DOM Helpers ────────────────────────────────────── */
function qs(sel, ctx) {
  return (ctx || document).querySelector(sel);
}
function qsAll(sel, ctx) {
  return Array.prototype.slice.call((ctx || document).querySelectorAll(sel));
}


/* ── Header scroll effect ───────────────────────────── */
var header = qs('#header');
window.addEventListener('scroll', function() {
  if (window.scrollY > 30) {
    header.classList.add('scrolled');
  } else {
    header.classList.remove('scrolled');
  }
});


/* ── Mobile navigation ──────────────────────────────── */
var hamburger = qs('#hamburger');
var navMenu   = qs('#nav-menu');

hamburger.addEventListener('click', function() {
  var isOpen = navMenu.classList.toggle('open');
  hamburger.classList.toggle('open', isOpen);
  hamburger.setAttribute('aria-label', isOpen ? '메뉴 닫기' : '메뉴 열기');
  document.body.style.overflow = isOpen ? 'hidden' : '';
});

// Close nav on link click
qsAll('.nav-link').forEach(function(link) {
  link.addEventListener('click', function() {
    navMenu.classList.remove('open');
    hamburger.classList.remove('open');
    document.body.style.overflow = '';
  });
});


/* ── Active nav link on scroll ──────────────────────── */
var sections = qsAll('section[id]');

function updateActiveNav() {
  var scrollY = window.scrollY + 120;
  sections.forEach(function(sec) {
    var top    = sec.offsetTop;
    var height = sec.offsetHeight;
    var id     = sec.getAttribute('id');
    var link   = qs('.nav-link[href="#' + id + '"]');
    if (!link) return;
    if (scrollY >= top && scrollY < top + height) {
      qsAll('.nav-link').forEach(function(l) { l.classList.remove('active'); });
      link.classList.add('active');
    }
  });
}
window.addEventListener('scroll', updateActiveNav);
updateActiveNav();


/* ── Scroll-to-top button ───────────────────────────── */
var scrollTopBtn = qs('#scroll-top');

window.addEventListener('scroll', function() {
  if (window.scrollY > 400) {
    scrollTopBtn.classList.add('visible');
  } else {
    scrollTopBtn.classList.remove('visible');
  }
});

scrollTopBtn.addEventListener('click', function() {
  window.scrollTo({ top: 0, behavior: 'smooth' });
});


/* ── Scroll reveal animation ────────────────────────── */
function addRevealClasses() {
  var targets = [
    '.service-card',
    '.stat-card',
    '.team-card',
    '.news-card',
    '.process-step',
    '.about-text',
    '.about-visual',
    '.contact-info',
    '.contact-form',
    '.section-header'
  ];

  targets.forEach(function(sel) {
    qsAll(sel).forEach(function(el, i) {
      el.classList.add('reveal');
      var delay = i % 4;
      if (delay > 0) el.classList.add('reveal-delay-' + delay);
    });
  });
}

function revealOnScroll() {
  var threshold = window.innerHeight * 0.88;
  qsAll('.reveal').forEach(function(el) {
    var top = el.getBoundingClientRect().top;
    if (top < threshold) el.classList.add('visible');
  });
}

addRevealClasses();
window.addEventListener('scroll', revealOnScroll);
revealOnScroll();


/* ── Animated counters ──────────────────────────────── */
function animateCounter(el, target, duration) {
  duration = duration || 1800;
  var startTime = performance.now();

  function update(currentTime) {
    var elapsed  = currentTime - startTime;
    var progress = Math.min(elapsed / duration, 1);
    var ease = 1 - Math.pow(1 - progress, 4);
    el.textContent = Math.floor(ease * target).toLocaleString();
    if (progress < 1) requestAnimationFrame(update);
  }
  requestAnimationFrame(update);
}

var statsObserver = new IntersectionObserver(function(entries) {
  entries.forEach(function(entry) {
    if (!entry.isIntersecting) return;
    var card    = entry.target;
    var target  = parseInt(card.dataset.count, 10);
    var countEl = card.querySelector('.count');
    if (countEl && target) {
      animateCounter(countEl, target);
      statsObserver.unobserve(card);
    }
  });
}, { threshold: 0.4 });

qsAll('.stat-card').forEach(function(card) {
  statsObserver.observe(card);
});


/* ── Contact form ───────────────────────────────────── */
var contactForm = qs('#contact-form');
var toast       = qs('#toast');

function showToast(message, type) {
  type = type || 'success';
  toast.textContent = message;
  toast.className   = 'toast ' + type + ' show';
  setTimeout(function() { toast.classList.remove('show'); }, 3500);
}

function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

contactForm.addEventListener('submit', function(e) {
  e.preventDefault();

  var name    = qs('#name').value.trim();
  var email   = qs('#email').value.trim();
  var message = qs('#message').value.trim();

  // Validation
  if (!name) {
    showToast('이름을 입력해주세요.', 'error');
    qs('#name').focus();
    return;
  }
  if (!validateEmail(email)) {
    showToast('유효한 이메일 주소를 입력해주세요.', 'error');
    qs('#email').focus();
    return;
  }
  if (!message) {
    showToast('문의 내용을 입력해주세요.', 'error');
    qs('#message').focus();
    return;
  }

  // Simulate submission
  var btn = contactForm.querySelector('.btn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> 전송 중...';

  setTimeout(function() {
    showToast('문의가 성공적으로 접수되었습니다. 빠른 시일 내 답변드리겠습니다.', 'success');
    contactForm.reset();
    btn.disabled = false;
    btn.innerHTML = '문의 보내기 <i class="fa-solid fa-paper-plane"></i>';
  }, 1200);
});


/* ── Input focus animation ──────────────────────────── */
qsAll('.form-group input, .form-group textarea, .form-group select').forEach(function(input) {
  input.addEventListener('focus', function() {
    input.parentElement.classList.add('focused');
  });
  input.addEventListener('blur', function() {
    input.parentElement.classList.remove('focused');
  });
});


/* ── Smooth internal link scrolling (fallback) ──────── */
qsAll('a[href^="#"]').forEach(function(anchor) {
  anchor.addEventListener('click', function(e) {
    var id  = anchor.getAttribute('href');
    var el  = (id !== '#') ? document.querySelector(id) : null;
    if (el) {
      e.preventDefault();
      el.scrollIntoView({ behavior: 'smooth' });
    }
  });
});


/* ── Cursor-aware card tilt effect (desktop only) ───── */
if (window.matchMedia('(hover: hover)').matches) {
  qsAll('.service-card, .team-card').forEach(function(card) {
    card.addEventListener('mousemove', function(e) {
      var rect = card.getBoundingClientRect();
      var x    = ((e.clientX - rect.left) / rect.width  - 0.5) * 10;
      var y    = ((e.clientY - rect.top)  / rect.height - 0.5) * -10;
      card.style.transform = 'perspective(800px) rotateY(' + x + 'deg) rotateX(' + y + 'deg) translateY(-6px)';
    });
    card.addEventListener('mouseleave', function() {
      card.style.transform = '';
    });
  });
}


/* ── Typewriter effect on hero badge ─────────────────── */
(function typewriterBadge() {
  var badge    = document.querySelector('.hero-badge');
  if (!badge) return;
  var full     = badge.textContent.trim();
  var icon     = badge.querySelector('i');
  var iconHtml = icon ? icon.outerHTML + ' ' : '';
  badge.innerHTML = iconHtml;

  var i    = 0;
  var text = full.replace(/^[\s\S]*?(?=2024)/, '');
  var interval = setInterval(function() {
    i++;
    badge.innerHTML = iconHtml + text.slice(0, i);
    if (i >= text.length) clearInterval(interval);
  }, 40);
}());


/* ── Page loader ────────────────────────────────────── */
window.addEventListener('load', function() {
  document.body.classList.add('loaded');
});


/* ══════════════════════════════════════════════════════
   PARTNER SLIDER  – 드래그(마우스/터치) + 관성 스크롤
══════════════════════════════════════════════════════ */
(function initPartnerSlider() {
  var wrap  = qs('.partner-slider-wrap');
  var track = qs('#partnerTrack');
  if (!wrap || !track) return;

  /* ── 상태 변수 ── */
  var isDragging   = false;
  var startX       = 0;
  var currentX     = 0;       // 드래그 중 실시간 X
  var translateX   = 0;       // 현재 적용된 translateX
  var lastX        = 0;
  var velocity     = 0;
  var rafId        = null;
  var clickBlocked = false;   // 드래그 후 클릭 방지

  /* ── 한계 계산 ── */
  function maxScroll() {
    return -(track.scrollWidth - wrap.offsetWidth);
  }

  /* ── translate 적용 ── */
  function applyTranslate(x) {
    var min = maxScroll();
    if (x > 0) x = 0;
    if (x < min) x = min;
    translateX = x;
    track.style.transform = 'translateX(' + x + 'px)';
  }

  /* ── 관성 감속 ── */
  function momentum() {
    velocity *= 0.92;
    var next = translateX + velocity;
    applyTranslate(next);
    if (Math.abs(velocity) > 0.5) {
      rafId = requestAnimationFrame(momentum);
    }
  }

  /* ── 마우스 이벤트 ── */
  wrap.addEventListener('mousedown', function(e) {
    isDragging   = true;
    clickBlocked = false;
    startX       = e.clientX - translateX;
    lastX        = e.clientX;
    velocity     = 0;
    cancelAnimationFrame(rafId);
    track.classList.add('dragging');
    e.preventDefault();
  });

  document.addEventListener('mousemove', function(e) {
    if (!isDragging) return;
    var dx = e.clientX - lastX;
    velocity = dx;
    lastX    = e.clientX;
    currentX = e.clientX - startX;

    // 4px 이상 움직이면 클릭 차단
    if (Math.abs(e.clientX - (startX + translateX)) > 4) {
      clickBlocked = true;
    }
    applyTranslate(currentX);
  });

  document.addEventListener('mouseup', function() {
    if (!isDragging) return;
    isDragging = false;
    track.classList.remove('dragging');
    rafId = requestAnimationFrame(momentum);
  });

  /* ── 터치 이벤트 ── */
  wrap.addEventListener('touchstart', function(e) {
    isDragging   = true;
    clickBlocked = false;
    startX       = e.touches[0].clientX - translateX;
    lastX        = e.touches[0].clientX;
    velocity     = 0;
    cancelAnimationFrame(rafId);
    track.classList.add('dragging');
  }, { passive: true });

  wrap.addEventListener('touchmove', function(e) {
    if (!isDragging) return;
    var dx = e.touches[0].clientX - lastX;
    velocity = dx;
    lastX    = e.touches[0].clientX;
    currentX = e.touches[0].clientX - startX;
    applyTranslate(currentX);
  }, { passive: true });

  wrap.addEventListener('touchend', function() {
    isDragging = false;
    track.classList.remove('dragging');
    rafId = requestAnimationFrame(momentum);
  });

  /* ── 클릭 차단 (드래그 후 링크 방지) ── */
  wrap.addEventListener('click', function(e) {
    if (clickBlocked) {
      e.preventDefault();
      e.stopPropagation();
      clickBlocked = false;
    }
  }, true);

  /* ── 윈도우 리사이즈 시 범위 재조정 ── */
  window.addEventListener('resize', function() {
    applyTranslate(translateX);
  });
}());
