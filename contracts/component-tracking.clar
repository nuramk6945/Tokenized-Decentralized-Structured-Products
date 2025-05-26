;; Component Tracking Contract
;; Records underlying asset composition and tracks changes

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_COMPONENT_NOT_FOUND (err u201))
(define-constant ERR_INVALID_WEIGHT (err u202))
(define-constant ERR_PRODUCT_NOT_FOUND (err u203))

;; Component data structure
(define-map product-components
  { product-id: uint, component-index: uint }
  {
    asset-symbol: (string-ascii 20),
    weight-percentage: uint,
    current-price: uint,
    last-updated: uint,
    active: bool
  }
)

;; Track number of components per product
(define-map product-component-count
  { product-id: uint }
  { count: uint }
)

;; Component price history
(define-map component-price-history
  { product-id: uint, component-index: uint, timestamp: uint }
  { price: uint }
)

;; Add component to product
(define-public (add-component
  (product-id uint)
  (asset-symbol (string-ascii 20))
  (weight-percentage uint)
  (initial-price uint))
  (let ((current-count (default-to u0 (get count (map-get? product-component-count { product-id: product-id })))))
    (asserts! (<= weight-percentage u100) ERR_INVALID_WEIGHT)

    ;; Add component
    (map-set product-components
      { product-id: product-id, component-index: current-count }
      {
        asset-symbol: asset-symbol,
        weight-percentage: weight-percentage,
        current-price: initial-price,
        last-updated: block-height,
        active: true
      }
    )

    ;; Update component count
    (map-set product-component-count
      { product-id: product-id }
      { count: (+ current-count u1) }
    )

    ;; Record initial price
    (map-set component-price-history
      { product-id: product-id, component-index: current-count, timestamp: block-height }
      { price: initial-price }
    )

    (ok current-count)
  )
)

;; Update component price
(define-public (update-component-price
  (product-id uint)
  (component-index uint)
  (new-price uint))
  (let ((component-data (unwrap! (map-get? product-components { product-id: product-id, component-index: component-index }) ERR_COMPONENT_NOT_FOUND)))
    (map-set product-components
      { product-id: product-id, component-index: component-index }
      (merge component-data {
        current-price: new-price,
        last-updated: block-height
      })
    )

    ;; Record price history
    (map-set component-price-history
      { product-id: product-id, component-index: component-index, timestamp: block-height }
      { price: new-price }
    )

    (ok true)
  )
)

;; Get component data
(define-read-only (get-component (product-id uint) (component-index uint))
  (map-get? product-components { product-id: product-id, component-index: component-index })
)

;; Get product component count
(define-read-only (get-component-count (product-id uint))
  (default-to u0 (get count (map-get? product-component-count { product-id: product-id })))
)

;; Calculate total portfolio value
(define-read-only (calculate-portfolio-value (product-id uint))
  (let ((component-count (get-component-count product-id)))
    (fold calculate-component-value (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9) { total: u0, product-id: product-id, max-index: component-count })
  )
)

(define-private (calculate-component-value (index uint) (acc { total: uint, product-id: uint, max-index: uint }))
  (if (< index (get max-index acc))
    (match (map-get? product-components { product-id: (get product-id acc), component-index: index })
      component-data
        (let ((component-value (* (get current-price component-data) (get weight-percentage component-data))))
          {
            total: (+ (get total acc) component-value),
            product-id: (get product-id acc),
            max-index: (get max-index acc)
          })
      acc)
    acc)
)
