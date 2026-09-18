/**
 * CDN jQuery 로딩 실패 시 사용하는 최소 호환 레이어.
 * - 목적: 내부망/오프라인 환경에서 dashboard.js, biz.js의 기본 DOM/AJAX 동작 보장
 * - 지원: $(selector), $(document).ready, $.ajax, $.each, val/text/html/attr/prop/class/css/append/remove/focus
 * - 반환: jQuery 호환 객체 또는 AJAX 결과 콜백
 */
(function(window, document) {
    'use strict';

    function toArray(value) {
        if (!value) {
            return [];
        }
        if (value instanceof JqLite) {
            return value.nodes;
        }
        if (value.nodeType || value === window) {
            return [value];
        }
        if (typeof value.length === 'number' && typeof value !== 'string') {
            return Array.prototype.slice.call(value);
        }
        return [];
    }

    function JqLite(nodes) {
        this.nodes = nodes || [];
        this.length = this.nodes.length;
        for (var i = 0; i < this.nodes.length; i++) {
            this[i] = this.nodes[i];
        }
    }

    JqLite.prototype.each = function(callback) {
        this.nodes.forEach(function(node, index) {
            callback.call(node, index, node);
        });
        return this;
    };

    JqLite.prototype.ready = function(callback) {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', callback);
        } else {
            callback();
        }
        return this;
    };

    JqLite.prototype.val = function(value) {
        if (value === undefined) {
            return this.length ? this.nodes[0].value : undefined;
        }
        return this.each(function() { this.value = value; });
    };

    JqLite.prototype.text = function(value) {
        if (value === undefined) {
            return this.length ? this.nodes[0].textContent : undefined;
        }
        return this.each(function() { this.textContent = value; });
    };

    JqLite.prototype.html = function(value) {
        if (value === undefined) {
            return this.length ? this.nodes[0].innerHTML : undefined;
        }
        return this.each(function() { this.innerHTML = value; });
    };

    JqLite.prototype.empty = function() {
        return this.html('');
    };

    JqLite.prototype.append = function(value) {
        return this.each(function() {
            if (typeof value === 'string') {
                this.insertAdjacentHTML('beforeend', value);
            } else {
                toArray(value).forEach(function(node) {
                    this.appendChild(node.cloneNode(true));
                }, this);
            }
        });
    };

    JqLite.prototype.attr = function(name, value) {
        if (value === undefined) {
            return this.length ? this.nodes[0].getAttribute(name) : undefined;
        }
        return this.each(function() { this.setAttribute(name, value); });
    };

    JqLite.prototype.prop = function(name, value) {
        if (value === undefined) {
            return this.length ? this.nodes[0][name] : undefined;
        }
        return this.each(function() { this[name] = value; });
    };

    JqLite.prototype.addClass = function(className) {
        var classes = String(className || '').split(/\s+/).filter(Boolean);
        return this.each(function() { this.classList.add.apply(this.classList, classes); });
    };

    JqLite.prototype.removeClass = function(className) {
        var classes = String(className || '').split(/\s+/).filter(Boolean);
        return this.each(function() { this.classList.remove.apply(this.classList, classes); });
    };

    JqLite.prototype.hasClass = function(className) {
        return this.length ? this.nodes[0].classList.contains(className) : false;
    };

    JqLite.prototype.css = function(name, value) {
        if (value === undefined) {
            return this.length ? window.getComputedStyle(this.nodes[0])[name] : undefined;
        }
        return this.each(function() { this.style[name] = value; });
    };

    JqLite.prototype.remove = function() {
        return this.each(function() {
            if (this.parentNode) {
                this.parentNode.removeChild(this);
            }
        });
    };

    JqLite.prototype.focus = function() {
        return this.each(function() { this.focus(); });
    };

    function $(selector) {
        if (typeof selector === 'function') {
            return $(document).ready(selector);
        }
        if (selector === document) {
            return new JqLite([document]);
        }
        if (typeof selector === 'string') {
            return new JqLite(Array.prototype.slice.call(document.querySelectorAll(selector)));
        }
        return new JqLite(toArray(selector));
    }

    /**
     * 배열/객체를 순회한다.
     * @param {Array|Object} target 순회 대상
     * @param {Function} callback 콜백(indexOrKey, value)
     * @returns {Array|Object} 원본 대상
     */
    $.each = function(target, callback) {
        if (!target) {
            return target;
        }
        if (Array.isArray(target) || typeof target.length === 'number') {
            for (var i = 0; i < target.length; i++) {
                if (callback.call(target[i], i, target[i]) === false) {
                    break;
                }
            }
        } else {
            for (var key in target) {
                if (Object.prototype.hasOwnProperty.call(target, key)) {
                    if (callback.call(target[key], key, target[key]) === false) {
                        break;
                    }
                }
            }
        }
        return target;
    };

    function serialize(data) {
        if (!data) {
            return '';
        }
        var params = [];
        for (var key in data) {
            if (Object.prototype.hasOwnProperty.call(data, key) && data[key] !== undefined && data[key] !== null) {
                params.push(encodeURIComponent(key) + '=' + encodeURIComponent(data[key]));
            }
        }
        return params.join('&');
    }

    /**
     * XMLHttpRequest 기반 AJAX를 수행한다.
     * @param {Object} options url, type, dataType, data, success, error
     * @returns {XMLHttpRequest} 요청 객체
     */
    $.ajax = function(options) {
        options = options || {};
        var method = (options.type || options.method || 'GET').toUpperCase();
        var query = serialize(options.data);
        var url = options.url || '';

        if (method === 'GET' && query) {
            url += (url.indexOf('?') === -1 ? '?' : '&') + query;
        }

        var xhr = new XMLHttpRequest();
        xhr.open(method, url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) {
                return;
            }
            var response = xhr.responseText;
            if ((options.dataType || '').toLowerCase() === 'json' && response) {
                try {
                    response = JSON.parse(response);
                } catch (e) {
                    if (typeof options.error === 'function') {
                        options.error(xhr, 'parsererror', e);
                    }
                    return;
                }
            }
            if (xhr.status >= 200 && xhr.status < 300) {
                if (typeof options.success === 'function') {
                    options.success(response, 'success', xhr);
                }
            } else if (typeof options.error === 'function') {
                options.error(xhr, 'error');
            }
        };

        if (method === 'GET') {
            xhr.send();
        } else {
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
            xhr.send(query);
        }
        return xhr;
    };

    $.fn = JqLite.prototype;
    window.$ = window.jQuery = $;
})(window, document);
