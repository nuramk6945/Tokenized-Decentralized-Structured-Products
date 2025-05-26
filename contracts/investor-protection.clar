;; Investor Protection Contract
;; Ensures appropriate risk disclosure and investor suitability

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u500))
(define-constant ERR_INVESTOR_NOT_FOUND (err u501))
(define-constant ERR_INSUFFICIENT_SUITABILITY (err u502))
(define-constant ERR_DISCLOSURE_NOT_ACKNOWLEDGED (err u503))
(define-constant ERR_PRODUCT_NOT_FOUND (err u504))

;; Investor suitability levels
(define-constant SUITABILITY_CONSERVATIVE u1)
(define-constant SUITABILITY_MODERATE u2)
(define-constant SUITABILITY_AGGRESSIVE u3)
(define-constant SUITABILITY_SOPHISTICATED u4)

;; Investor profile data
(define-map investor-profiles
  { investor: principal }
  {
    suitability-level: uint,
    risk-tolerance: uint,
    investment-experience: uint,
    net-worth-category: uint,
    profile-updated: uint,
    kyc-verified: bool
  }
)

;; Risk disclosure acknowledgments
(define-map risk-disclosures
  { investor: principal, product-id: uint }
  {
    acknowledged: bool,
    acknowledgment-timestamp: uint,
    disclosure-version: uint
  }
)

;; Product suitability requirements
(define-map product-suitability-requirements
  { product-id: uint }
  {
    minimum-suitability-level: uint,
    minimum-net-worth: uint,
    requires-sophisticated-investor: bool,
    additional-disclosures: (list 5 (string-ascii 100))
  }
)

;; Authorized compliance officers
(define-map authorized-compliance-officers principal bool)

;; Initialize contract owner as compliance officer
(map-set authorized-compliance-officers CONTRACT_OWNER true)

;; Add compliance officer
(define-public (add-compliance-officer (officer principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (map-set authorized-compliance-officers officer true))
  )
)

;; Update investor profile
(define-public (update-investor-profile
  (investor principal)
  (suitability-level uint)
  (risk-tolerance uint)
  (investment-experience uint)
  (net-worth-category uint))
  (begin
    (asserts! (or (is-eq tx-sender investor) (default-to false (map-get? authorized-compliance-officers tx-sender))) ERR_UNAUTHORIZED)

    (map-set investor-profiles
      { investor: investor }
      {
        suitability-level: suitability-level,
        risk-tolerance: risk-tolerance,
        investment-experience: investment-experience,
        net-worth-category: net-worth-category,
        profile-updated: block-height,
        kyc-verified: true
      }
    )
    (ok true)
  )
)

;; Set product suitability requirements
(define-public (set-product-requirements
  (product-id uint)
  (minimum-suitability-level uint)
  (minimum-net-worth uint)
  (requires-sophisticated-investor bool)
  (additional-disclosures (list 5 (string-ascii 100))))
  (begin
    (asserts! (default-to false (map-get? authorized-compliance-officers tx-sender)) ERR_UNAUTHORIZED)

    (map-set product-suitability-requirements
      { product-id: product-id }
      {
        minimum-suitability-level: minimum-suitability-level,
        minimum-net-worth: minimum-net-worth,
        requires-sophisticated-investor: requires-sophisticated-investor,
        additional-disclosures: additional-disclosures
      }
    )
    (ok true)
  )
)

;; Acknowledge risk disclosure
(define-public (acknowledge-risk-disclosure (product-id uint))
  (let ((investor-profile (unwrap! (map-get? investor-profiles { investor: tx-sender }) ERR_INVESTOR_NOT_FOUND)))
    (map-set risk-disclosures
      { investor: tx-sender, product-id: product-id }
      {
        acknowledged: true,
        acknowledgment-timestamp: block-height,
        disclosure-version: u1
      }
    )
    (ok true)
  )
)

;; Check investor suitability for product
(define-public (check-investor-suitability (investor principal) (product-id uint))
  (let (
    (investor-profile (unwrap! (map-get? investor-profiles { investor: investor }) ERR_INVESTOR_NOT_FOUND))
    (product-requirements (unwrap! (map-get? product-suitability-requirements { product-id: product-id }) ERR_PRODUCT_NOT_FOUND))
    (disclosure-ack (map-get? risk-disclosures { investor: investor, product-id: product-id }))
  )
    ;; Check suitability level
    (asserts! (>= (get suitability-level investor-profile) (get minimum-suitability-level product-requirements)) ERR_INSUFFICIENT_SUITABILITY)

    ;; Check net worth requirement
    (asserts! (>= (get net-worth-category investor-profile) (get minimum-net-worth product-requirements)) ERR_INSUFFICIENT_SUITABILITY)

    ;; Check sophisticated investor requirement
    (asserts! (or (not (get requires-sophisticated-investor product-requirements))
                  (is-eq (get suitability-level investor-profile) SUITABILITY_SOPHISTICATED)) ERR_INSUFFICIENT_SUITABILITY)

    ;; Check risk disclosure acknowledgment
    (asserts! (default-to false (get acknowledged disclosure-ack)) ERR_DISCLOSURE_NOT_ACKNOWLEDGED)

    (ok true)
  )
)

;; Get investor profile
(define-read-only (get-investor-profile (investor principal))
  (map-get? investor-profiles { investor: investor })
)

;; Get product requirements
(define-read-only (get-product-requirements (product-id uint))
  (map-get? product-suitability-requirements { product-id: product-id })
)

;; Check if disclosure is acknowledged
(define-read-only (is-disclosure-acknowledged (investor principal) (product-id uint))
  (default-to false (get acknowledged (map-get? risk-disclosures { investor: investor, product-id: product-id })))
)

;; Generate suitability report
(define-read-only (generate-suitability-report (investor principal) (product-id uint))
  (match (map-get? investor-profiles { investor: investor })
    investor-profile
      (match (map-get? product-suitability-requirements { product-id: product-id })
        product-req
          (some {
            investor-suitable: (and
              (>= (get suitability-level investor-profile) (get minimum-suitability-level product-req))
              (>= (get net-worth-category investor-profile) (get minimum-net-worth product-req))
              (or (not (get requires-sophisticated-investor product-req))
                  (is-eq (get suitability-level investor-profile) SUITABILITY_SOPHISTICATED))),
            disclosure-acknowledged: (is-disclosure-acknowledged investor product-id),
            investor-suitability-level: (get suitability-level investor-profile),
            required-suitability-level: (get minimum-suitability-level product-req)
          })
        none)
    none)
)
