;; Accounting Firm Verification Contract
;; This contract validates accounting service providers

(define-data-var admin principal tx-sender)

;; Data map to store verified accounting firms
(define-map verified-firms
  { firm-id: (string-ascii 64) }
  {
    name: (string-ascii 256),
    license-number: (string-ascii 64),
    verified: bool,
    verification-date: uint,
    expiration-date: uint
  }
)

;; Public function to register a new accounting firm
(define-public (register-firm (firm-id (string-ascii 64)) (name (string-ascii 256)) (license-number (string-ascii 64)) (expiration-date uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? verified-firms { firm-id: firm-id })) (err u100))
    (ok (map-set verified-firms
      { firm-id: firm-id }
      {
        name: name,
        license-number: license-number,
        verified: false,
        verification-date: u0,
        expiration-date: expiration-date
      }
    ))
  )
)

;; Public function to verify an accounting firm
(define-public (verify-firm (firm-id (string-ascii 64)))
  (let ((firm-data (unwrap! (map-get? verified-firms { firm-id: firm-id }) (err u404))))
    (begin
      (asserts! (is-eq tx-sender (var-get admin)) (err u403))
      (ok (map-set verified-firms
        { firm-id: firm-id }
        (merge firm-data {
          verified: true,
          verification-date: block-height
        })
      ))
    )
  )
)

;; Public function to check if a firm is verified
(define-read-only (is-firm-verified (firm-id (string-ascii 64)))
  (let ((firm-data (map-get? verified-firms { firm-id: firm-id })))
    (if (is-some firm-data)
      (get verified (unwrap! firm-data false))
      false
    )
  )
)

;; Public function to get firm details
(define-read-only (get-firm-details (firm-id (string-ascii 64)))
  (map-get? verified-firms { firm-id: firm-id })
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
