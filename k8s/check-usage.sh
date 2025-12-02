#!/bin/bash
echo "=== Resource Usage Report ==="
echo "Date: $(date)"
echo ""
echo "Current Pod Metrics:"
kubectl top pods -l app=guestbook --containers
echo ""
echo "HPA Status:"
kubectl get hpa guestbook-hpa
echo ""
echo "Pod Count:"
kubectl get pods -l app=guestbook --no-headers | wc -l
